// LoginState.swift

enum LoginState {
    case phoneNumber, email, emailCode, code, twoFactor

    // MARK: Internal

    var title: String {
        switch self {
        case .phoneNumber: "Phone number"
        case .email: "Email"
        case .emailCode: "Email code"
        case .code: "Code"
        case .twoFactor: "2FA"
        }
    }
}
