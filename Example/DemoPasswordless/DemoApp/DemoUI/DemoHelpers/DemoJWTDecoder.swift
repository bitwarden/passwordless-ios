import Foundation

extension String {
    func base64URLDecodedData() -> Data? {
        var base64 = self
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let paddingLength = (4 - base64.count % 4) % 4
        base64 += String(repeating: "=", count: paddingLength)

        return Data(base64Encoded: base64)
    }

    func decodeJWT() throws -> [String: Any] {
        let segments = components(separatedBy: ".")
        let data = segments[1].base64URLDecodedData()!
        let json = try JSONSerialization.jsonObject(with: data)
        return (json as? [String: Any]) ?? [:]
    }

    func decodedUserName() throws -> String? {
        let decodedJWT = try decodeJWT()
        return decodedJWT["nameid"]  as? String
    }
}
