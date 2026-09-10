import Foundation

enum AICockpitOutputProjection {
    static func project(_ result: AICockpitCommandResult, compact: Bool, sections: String?, markdown: Bool) -> AICockpitCommandResult {
        guard var object = (try? JSONSerialization.jsonObject(with: Data(result.standardOutput.utf8))) as? [String: Any] else { return result }
        if let sections {
            let requested = Set(sections.split(separator: ",").map(String.init))
            if let packet = object["taskPacket"] as? [String: Any] {
                object["taskPacket"] = packet.filter { requested.contains($0.key) }
                object.removeValue(forKey: "workItem")
                object.removeValue(forKey: "evidence")
            } else {
                object = object.filter { requested.contains($0.key) || ["status", "kind", "message"].contains($0.key) }
            }
        }
        if compact {
            object.removeValue(forKey: "backendCapabilities")
            object.removeValue(forKey: "message")
            let kind = object["kind"] as? String ?? ""
            let mutation = ["Creation", "Update", "Status", "Links", "Submission", "Materialization", "Attachment"].contains { kind.hasSuffix($0) }
            if mutation {
                if let item = object["workItem"] as? [String: Any] {
                    object["workItem"] = item.filter { ["id", "kind", "status"].contains($0.key) }
                }
                if let plan = object["plan"] as? [String: Any] {
                    object["plan"] = plan.filter { ["id", "decisionState"].contains($0.key) }
                }
            }
            object = object.filter { !($0.value is [Any] && ($0.value as! [Any]).isEmpty) }
        }
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: [.sortedKeys]) else { return result }
        let json = String(decoding: data, as: UTF8.self)
        return AICockpitCommandResult(exitCode: result.exitCode, standardOutput: markdown ? "```json\n\(json)\n```" : json, standardError: result.standardError)
    }
}
