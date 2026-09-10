import Foundation

/// Usage and machine discovery are projections of the same command catalog.
enum AICockpitDiscovery {
    struct Entry: Codable {
        var command: String
        var usage: String
        var options: [String]
    }

    static var entries: [Entry] {
        var result: [Entry] = []
        let extra = """
        aicockpit schema [--command group.action] [--output json]
        aicockpit plans materialize PLAN-ID [--config path] [--output markdown|json]
        """
        for line in (AICockpitCommand.helpText() + "\n" + extra).split(separator: "\n") {
            let words = line.split(separator: " ").map(String.init)
            guard words.first == "aicockpit", words.count > 1, !words[1].hasPrefix("--") else { continue }
            let groups = words[1].split(separator: "|").map(String.init)
            let actions = words.count > 2 && words[2].first?.isLowercase == true
                ? words[2].split(separator: "|").map(String.init) : [""]
            for group in groups {
                for action in actions {
                    let command = action.isEmpty ? group : "\(group).\(action)"
                    var usage = line.trimmingCharacters(in: .whitespaces)
                        .replacingOccurrences(of: words[1], with: group)
                    if actions.count > 1 { usage = usage.replacingOccurrences(of: words[2], with: action) }
                    if group == "task", ["create", "update", "propose"].contains(action) {
                        usage += " [--github number] [--epic EP-ID] [--sprint SP-ID] [--priority low|medium|high|critical] [--acceptance text] [--scope text] [--constraint text] [--evidence-required text] [--protected-path path]"
                        if action == "update" { usage += " [--report-format text]" }
                    }
                    if command == "state.diagnostics" { usage += " [--id ID]" }
                    if command == "plans.submit" { usage += " [--structure path]" }
                    if action == "inspect" || action == "packet" { usage += " [--sections names]" }
                    usage += " [--compact] [--root path] [--output markdown|json]"
                    let options = Set(usage.split { !$0.isLetter && !$0.isNumber && $0 != "-" }.map(String.init).filter { $0.hasPrefix("--") })
                    result.append(Entry(command: command, usage: usage, options: options.sorted()))
                }
            }
        }
        return result.sorted { $0.command < $1.command }
    }

    static func help(_ positionals: [String]) -> String {
        guard let group = positionals.first else { return AICockpitCommand.helpText() }
        let key = positionals.prefix(2).joined(separator: ".")
        let matches = entries.filter { $0.command == key || (positionals.count == 1 && $0.command.hasPrefix(group + ".")) }
        guard !matches.isEmpty else { return "Unknown command: \(key). Use aicockpit --help." }
        return matches.map(\.usage).joined(separator: "\n") + "\nRepeated text options accept multiple occurrences. --sections uses comma-separated section names."
    }

    static func schema(command: String?) -> String {
        struct Schema: Encodable { let schemaVersion = "1.0.0"; let commands: [Entry] }
        let selected = entries.filter { command == nil || $0.command == command || $0.command.hasPrefix(command! + ".") }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return String(decoding: try! encoder.encode(Schema(commands: selected)), as: UTF8.self)
    }
}
