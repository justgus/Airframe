public struct AirframeCoreInfo: Sendable {
    public let name: String
    public let version: String

    public init(
        name: String = "AirframeCore",
        version: String = "0.1.0"
    ) {
        self.name = name
        self.version = version
    }

    public static let current = AirframeCoreInfo()

    public var summary: String {
        "\(name) \(version)"
    }
}
