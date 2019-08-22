import Foundation

public class WebRequestOAuthSession: WebRequestSession {

    public let accessToken: String
    public let expiresIn: Double
    public let idToken: String
    public let refreshToken: String
    public let scope: String
    public let tokenType: String

    public var debugDescription: String {
        return "WebRequestOAuthSession {\n"
            + "\taccessToken: \(accessToken),\n"
            + "\texpiresIn: \(expiresIn),\n"
            + "\tidToken: \(idToken),\n"
            + "\trefreshToken: \(refreshToken),\n"
            + "\tscope: \(scope),\n"
            + "\ttokenType: \(tokenType)\n"
            + "}"
    }

    required init(accessToken: String,
                  expiresIn: Double,
                  idToken: String,
                  refreshToken: String,
                  scope: String,
                  tokenType: String) {
        self.accessToken = accessToken
        self.expiresIn = expiresIn
        self.idToken = idToken
        self.refreshToken = refreshToken
        self.scope = scope
        self.tokenType = tokenType
    }
}
