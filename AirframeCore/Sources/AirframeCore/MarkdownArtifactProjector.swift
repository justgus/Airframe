import Foundation

public struct AirframeMarkdownArtifactProjector: Sendable {
    public init() {}

    public func projectEpic(_ record: AirframeCanonicalEpicRecord) -> String {
        var lines: [String] = [
            "# \(record.workItem.id.rawValue): \(record.workItem.title)",
            "",
            "**Status:** \(record.workItem.status.description)",
            "**Owner:** \(record.owner)",
            "**Start Date:** \(record.startDate ?? "TBD")",
            "**Target Close Date:** \(record.targetCloseDate ?? "TBD")",
            "**Close Date:** \(record.closeDate ?? "TBD")",
            "",
            "**Goal:**",
            record.goal,
            "",
            "**Rationale:**",
            record.rationale
        ]
        appendList("Scope", record.scope, to: &lines)
        appendList("Out of Scope", record.outOfScope, to: &lines)
        appendTable(
            title: "Related Sprints",
            headers: ["Sprint", "Status"],
            rows: record.sprintIDs.map { [$0.rawValue, ""] },
            to: &lines
        )
        appendTable(
            title: "Related Tasks",
            headers: ["Task", "Status"],
            rows: record.taskIDs.map { [$0.rawValue, ""] },
            to: &lines
        )
        appendTable(
            title: "Related Issues",
            headers: ["Issue", "Status"],
            rows: record.issueIDs.map { [$0.rawValue, ""] },
            to: &lines
        )
        appendList("Notes", record.notes, to: &lines)
        return finish(lines)
    }

    public func projectSprint(_ record: AirframeCanonicalSprintRecord) -> String {
        var lines: [String] = [
            "# \(record.workItem.id.rawValue): \(record.workItem.title)",
            "",
            "**Status:** \(record.workItem.status.description)",
            "**Epic:** \(record.epicID?.rawValue ?? "TBD")",
            "**Goal:** \(record.goal)",
            "**Start Date:** \(record.startDate ?? "TBD")",
            "**End Date:** \(record.endDate ?? "TBD")",
            "**Capacity:** \(record.capacity ?? "TBD")"
        ]
        appendTable(
            title: "Assigned Tasks",
            headers: ["Task", "Status"],
            rows: record.taskIDs.map { [$0.rawValue, ""] },
            to: &lines
        )
        appendTable(
            title: "Assigned Issues",
            headers: ["Issue", "Status"],
            rows: record.issueIDs.map { [$0.rawValue, ""] },
            emptyText: "None.",
            to: &lines
        )
        appendList("Notes", record.notes, to: &lines)
        return finish(lines)
    }

    public func projectTask(_ record: AirframeCanonicalTaskRecord) -> String {
        var lines: [String] = [
            "## \(record.workItem.id.rawValue): \(record.workItem.title)",
            "",
            "**Status:** \(record.workItem.status.description)",
            "**GitHub Issue:** \(record.workItem.githubIssue.map { "#\($0)" } ?? "TBD")",
            "**Component:** \(record.component.isEmpty ? "TBD" : record.component)",
            "**Priority:** \(record.priority.description)",
            "**Epic:** \(record.epicID?.rawValue ?? "TBD")",
            "**Sprint Assigned:** \(record.sprintID?.rawValue ?? "TBD")",
            "**Date Requested:** \(record.dateRequested ?? "TBD")",
            "**Date Implemented:** \(record.dateImplemented ?? "TBD")",
            "**Date Verified:** \(record.dateVerified ?? "TBD")",
            "",
            "**Rationale:**",
            record.rationale
        ]
        appendNumbered("Acceptance Criteria", record.acceptanceCriteria, to: &lines)
        appendOptionalBlock("Implementation Notes", record.implementationDetails, to: &lines)
        appendList("Test Steps", record.testSteps, to: &lines)
        appendEvidence(record.evidenceIDs, to: &lines)
        appendList("Notes", record.notes, to: &lines)
        return finish(lines)
    }

    public func projectIssue(_ record: AirframeCanonicalIssueRecord) -> String {
        var lines: [String] = [
            "## \(record.workItem.id.rawValue): \(record.workItem.title)",
            "",
            "**Status:** \(record.workItem.status.description)",
            "**GitHub Issue:** \(record.workItem.githubIssue.map { "#\($0)" } ?? "TBD")",
            "**Severity:** \(record.severity.description)",
            "**Epic:** \(record.epicID?.rawValue ?? "TBD")",
            "**Sprint Assigned:** \(record.sprintID?.rawValue ?? "TBD")",
            "**Date Reported:** \(record.dateReported ?? "TBD")",
            "**Date Resolved:** \(record.dateResolved ?? "TBD")",
            "**Date Verified:** \(record.dateVerified ?? "TBD")",
            "",
            "**Observed Behavior:**",
            record.observedBehavior,
            "",
            "**Expected Behavior:**",
            record.expectedBehavior
        ]
        appendNumbered("Reproduction Steps", record.reproductionSteps, to: &lines)
        appendList("Affected Components", record.affectedComponents, to: &lines)
        appendEvidence(record.evidenceIDs, to: &lines)
        appendList("Notes", record.notes, to: &lines)
        return finish(lines)
    }

    public func projectTaskIndex(_ tasks: [AirframeCanonicalTaskRecord]) -> String {
        let sortedTasks = tasks.sorted { $0.workItem.id.rawValue < $1.workItem.id.rawValue }
        let groups = Dictionary(grouping: sortedTasks, by: { $0.workItem.status })
        var lines: [String] = [
            "# Tasks - Index",
            "",
            "Currently: **\(sortedTasks.count) total Tasks**",
            "",
            "| Status | Count |",
            "| ------ | ----- |"
        ]
        for status in taskIndexStatuses {
            lines.append("| \(status.description) | \(groups[status, default: []].count) |")
        }
        lines.append("")
        lines.append("| Task | GitHub Issue | Title | Status |")
        lines.append("| ---- | ------------ | ----- | ------ |")
        for task in sortedTasks {
            lines.append(
                "| \(task.workItem.id.rawValue) | \(task.workItem.githubIssue.map { "#\($0)" } ?? "TBD") | \(task.workItem.title) | \(task.workItem.status.description) |"
            )
        }
        return finish(lines)
    }

    private var taskIndexStatuses: [AirframeWorkStatus] {
        [.backlog, .active, .implementedNotVerified, .implementedVerified, .closed]
    }

    private func appendOptionalBlock(_ title: String, _ text: String?, to lines: inout [String]) {
        guard let text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        lines.append("")
        lines.append("**\(title):**")
        lines.append(text)
    }

    private func appendNumbered(_ title: String, _ values: [String], to lines: inout [String]) {
        guard !values.isEmpty else { return }
        lines.append("")
        lines.append("**\(title):**")
        for (index, value) in values.enumerated() {
            lines.append("\(index + 1). \(value)")
        }
    }

    private func appendList(_ title: String, _ values: [String], to lines: inout [String]) {
        guard !values.isEmpty else { return }
        lines.append("")
        lines.append("**\(title):**")
        for value in values {
            lines.append("- \(value)")
        }
    }

    private func appendEvidence(_ ids: [AirframeID], to lines: inout [String]) {
        lines.append("")
        lines.append("**Evidence:**")
        if ids.isEmpty {
            lines.append("- TBD")
        } else {
            for id in ids {
                lines.append("- \(id.rawValue)")
            }
        }
    }

    private func appendTable(
        title: String,
        headers: [String],
        rows: [[String]],
        emptyText: String? = nil,
        to lines: inout [String]
    ) {
        guard !rows.isEmpty else {
            if let emptyText {
                lines.append("")
                lines.append("### \(title)")
                lines.append("")
                lines.append(emptyText)
            }
            return
        }
        lines.append("")
        lines.append("### \(title)")
        lines.append("")
        lines.append("| \(headers.joined(separator: " | ")) |")
        lines.append("| \(headers.map { _ in "----" }.joined(separator: " | ")) |")
        for row in rows {
            lines.append("| \(row.joined(separator: " | ")) |")
        }
    }

    private func finish(_ lines: [String]) -> String {
        lines.joined(separator: "\n") + "\n"
    }
}
