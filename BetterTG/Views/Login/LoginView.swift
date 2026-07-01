// LoginView.swift

import Combine
import SwiftUI
import TDLibKit

struct LoginView: View {
    // MARK: Internal

    @State var loginState = LoginState.phoneNumber

    @State var showSelectCountryView = false
    @State var selectedCountryNum = PhoneNumberInfo(country: "RU", phoneNumberPrefix: "7", name: "Russian Federation")

    @State var phoneNumber = ""
    @State var email = ""
    @State var emailCode = ""
    @State var code = ""
    @State var hint = ""
    @State var twoFactor = ""

    @State var errorShown = false
    @State var errorMessage = ""
    @State var waitPremiumErrorShown = false
    @State var isSubmitting = false
    @FocusState var focused: LoginState?

    var body: some View {
        ZStack {
            Group {
                switch loginState {
                case .phoneNumber:
                    loginStateView {
                        GroupBox {
                            HStack {
                                Text("+\(selectedCountryNum.phoneNumberPrefix)")

                                TextField("Phone Number", text: $phoneNumber)
                                    .focused($focused, equals: .phoneNumber)
                                    .keyboardType(.phonePad)
                                    .textContentType(.telephoneNumber)
                            }
                        } label: {
                            Button(selectedCountryNum.name) {
                                showSelectCountryView.toggle()
                            }
                        }
                    }
                    .sheet(isPresented: $showSelectCountryView) {
                        SelectCountryView(
                            showSelectCountryView: $showSelectCountryView,
                            selectedCountryNum: $selectedCountryNum,
                        )
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.hidden)
                    }
                case .email:
                    loginStateView {
                        TextField("Email", text: $email)
                            .focused($focused, equals: .email)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding()
                            .background(Color.gray6)
                            .clipShape(.rect(cornerRadius: 10))
                    }
                case .emailCode:
                    loginStateView {
                        TextField("Email code", text: $emailCode)
                            .focused($focused, equals: .emailCode)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color.gray6)
                            .clipShape(.rect(cornerRadius: 10))
                    }
                case .code:
                    loginStateView {
                        TextField("Code", text: $code)
                            .focused($focused, equals: .code)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color.gray6)
                            .clipShape(.rect(cornerRadius: 10))
                    }
                case .twoFactor:
                    loginStateView {
                        SecureField(hint.isEmpty ? "2FA" : hint, text: $twoFactor)
                            .focused($focused, equals: .twoFactor)
                            .textContentType(.password)
                            .keyboardType(.alphabet)
                            .padding()
                            .background(Color.gray6)
                            .clipShape(.rect(cornerRadius: 10))
                    }
                }
            }
            .transition(
                .asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading),
                )
                .combined(with: .opacity),
            )
        }
        .animation(.default, value: loginState)
        .safeAreaInset(edge: .bottom) {
            Button {
                Task { await handleContinue() }
            } label: {
                Group {
                    if isSubmitting {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Continue")
                            .padding(.vertical, 5)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isSubmitting || !canContinue)
            .padding()
        }
        .alert("Error", isPresented: $errorShown) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .alert("Error", isPresented: $waitPremiumErrorShown) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("In order to login, you need to upgrade to Telegram Premium. Please, do it in the Telegram app.")
        }
        .task {
            await syncLoginStateFromAuthorization()
        }
        .onAppear {
            setPublishers()
            focused = loginState
        }
        .onChange(of: loginState) { _, newValue in
            focused = newValue
        }
    }

    func loginStateView(_ content: () -> some View) -> some View {
        VStack(spacing: 10) {
            Spacer()
            Text(loginState.title)
                .font(.system(.largeTitle, weight: .bold))
            Spacer()
            content()
            Spacer()
        }
        .padding()
    }

    // MARK: Private

    @State private var cancellables = Set<AnyCancellable>()

    private var canContinue: Bool {
        switch loginState {
        case .phoneNumber:
            !phoneDigits.isEmpty
        case .email:
            email.contains("@")
        case .emailCode:
            !emailCode.isEmpty
        case .code:
            !code.isEmpty
        case .twoFactor:
            !twoFactor.isEmpty
        }
    }

    private var phoneDigits: String {
        phoneNumber.filter(\.isNumber)
    }

    private var fullPhoneNumber: String {
        "+\(selectedCountryNum.phoneNumberPrefix)\(phoneDigits)"
    }

    private func showError(_ message: String) async {
        await MainActor.run {
            errorMessage = message
            errorShown = true
        }
    }

    private func syncLoginStateFromAuthorization() async {
        guard let authState = try? await td.getAuthorizationState() else { return }
        await MainActor.run { applyAuthorizationState(authState) }
    }

    @MainActor
    private func applyAuthorizationState(_ authState: AuthorizationState) {
        switch authState {
        case .authorizationStateWaitPhoneNumber:
            loginState = .phoneNumber
        case .authorizationStateWaitEmailAddress:
            loginState = .email
        case .authorizationStateWaitEmailCode:
            loginState = .emailCode
        case .authorizationStateWaitCode:
            loginState = .code
        case .authorizationStateWaitPassword(let waitPassword):
            loginState = .twoFactor
            hint = waitPassword.passwordHint
        case .authorizationStateClosed, .authorizationStateClosing, .authorizationStateLoggingOut:
            errorMessage = "Authorization failed. Please restart the app."
            errorShown = true
        case .authorizationStateWaitPremiumPurchase:
            waitPremiumErrorShown = true
        default:
            break
        }
    }

    private func handleContinue() async {
        await MainActor.run { isSubmitting = true }
        defer { Task { await MainActor.run { isSubmitting = false } } }

        do {
            let authState = try await td.getAuthorizationState()

            switch authState {
            case .authorizationStateWaitPhoneNumber:
                guard !phoneDigits.isEmpty else {
                    await showError("Enter your phone number.")
                    return
                }
                try await td.setAuthenticationPhoneNumber(
                    phoneNumber: fullPhoneNumber,
                    settings: nil,
                )

            case .authorizationStateWaitEmailAddress:
                let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
                guard trimmedEmail.contains("@") else {
                    await showError("Enter a valid email address.")
                    return
                }
                try await td.setAuthenticationEmailAddress(
                    emailAddress: trimmedEmail,
                    allowUserSecretEmails: true,
                    onlyAllowLoginEmails: false,
                )

            case .authorizationStateWaitEmailCode:
                guard !emailCode.isEmpty else {
                    await showError("Enter the code from your email.")
                    return
                }
                try await td.checkAuthenticationEmailCode(code: emailCode)

            case .authorizationStateWaitCode:
                guard !code.isEmpty else {
                    await showError("Enter the code from Telegram.")
                    return
                }
                try await td.checkAuthenticationCode(code: code)

            case .authorizationStateWaitPassword:
                guard !twoFactor.isEmpty else {
                    await showError("Enter your password.")
                    return
                }
                try await td.checkAuthenticationPassword(password: twoFactor)

            case .authorizationStateWaitTdlibParameters:
                await showError("App is still starting. Wait a few seconds and try again.")

            default:
                await showError("Cannot continue right now. Restart the app and try again.")
            }
        } catch {
            log("Login error: \(error)")
            await showError(error.localizedDescription)
        }
    }

    private func setPublishers() {
        nc.publisher(&cancellables, for: .authorizationStateWaitPassword) { notification in
            guard let waitPassword = notification.object as? AuthorizationStateWaitPassword else { return }
            Task.main {
                loginState = .twoFactor
                withAnimation { hint = waitPassword.passwordHint }
            }
        }
        nc.publisher(&cancellables, for: .authorizationStateWaitCode) { _ in
            Task.main { loginState = .code }
        }
        nc.publisher(&cancellables, for: .authorizationStateWaitEmailAddress) { _ in
            Task.main { loginState = .email }
        }
        nc.publisher(&cancellables, for: .authorizationStateWaitEmailCode) { _ in
            Task.main { loginState = .emailCode }
        }
        nc.mergeMany(&cancellables, [
            .authorizationStateWaitPhoneNumber,
            .authorizationStateClosed,
            .authorizationStateClosing,
            .authorizationStateLoggingOut,
        ]) { _ in
            Task.main { loginState = .phoneNumber }
        }
    }
}
