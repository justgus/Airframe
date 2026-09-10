import Foundation
import Testing
@testable import AirframeCore

@Test func sp046MaterializationRequiresApprovalAndRollsBackInvalidReferences() throws {
    let root = FileManager.default.temporaryDirectory.appending(path: "sp046-\(UUID())")
    defer { try? FileManager.default.removeItem(at: root) }
    let repository = AirframeCanonicalStoreRepository(rootURL: root)
    try repository.store.save(
        AirframeCanonicalProjectRecord(
            id: AirframeID("PRJ-AIRFRAME"),
            name: "Agile Airframe",
            repository: "justgus/Airframe"
        )
    )
    let epic = AirframeLocalWorkRecord(workItem: AirframeWorkItem(id: AirframeID("EP-9900"), kind: .epic, title: "Planned epic", status: .backlog))
    let invalidTask = AirframeLocalWorkRecord(workItem: AirframeWorkItem(id: AirframeID("T-9900"), kind: .task, title: "Planned task", status: .backlog), epicID: epic.workItem.id, sprintID: AirframeID("SP-MISSING"))
    let id = AirframeID("PLAN-9900")
    try repository.store.save(AirframeCanonicalImplementationPlanRecord(id: id, title: "Plan", summary: "Test", proposedByActorID: AirframeID("ACTOR-LLM"), proposedWork: [epic]))
    #expect(throws: (any Error).self) { try repository.materializePlan(id) }
    #expect(try repository.workRecords().isEmpty)
    try repository.store.save(AirframeCanonicalImplementationPlanRecord(id: id, title: "Plan", summary: "Test", proposedByActorID: AirframeID("ACTOR-LLM"), decisionState: .approved, proposedWork: [invalidTask, epic]))
    #expect(throws: (any Error).self) { try repository.materializePlan(id) }
    #expect(try repository.workRecords().isEmpty)
    let task = AirframeLocalWorkRecord(workItem: invalidTask.workItem, epicID: epic.workItem.id)
    try repository.store.save(AirframeCanonicalImplementationPlanRecord(id: id, title: "Plan", summary: "Test", proposedByActorID: AirframeID("ACTOR-LLM"), decisionState: .approved, proposedWork: [task, epic]))
    #expect(try repository.materializePlan(id).count == 2)
    let saved = try #require(try repository.store.load(AirframeCanonicalEpicRecord.self, id: epic.workItem.id))
    #expect(saved.taskIDs == [task.workItem.id])
    #expect(throws: (any Error).self) { try repository.materializePlan(id) }
    #expect(try repository.workRecords().count == 2)
}
