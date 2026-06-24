import Foundation

public struct AirframeCanonicalSchemaVersion: Codable, Equatable, Sendable {
    public let major: Int
    public let minor: Int
    public let patch: Int

    public init(major: Int, minor: Int = 0, patch: Int = 0) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    public static let current = AirframeCanonicalSchemaVersion(major: 1)
}

public struct AirframeCanonicalRecordMetadata: Codable, Equatable, Sendable {
    public let schemaVersion: AirframeCanonicalSchemaVersion
    public let createdAt: Date?
    public let updatedAt: Date?
    public let source: String?

    public init(
        schemaVersion: AirframeCanonicalSchemaVersion = .current,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        source: String? = nil
    ) {
        self.schemaVersion = schemaVersion
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.source = source
    }
}

public struct AirframeCanonicalWorkspaceRecord: Codable, Equatable, Sendable {
    public let metadata: AirframeCanonicalRecordMetadata
    public let id: AirframeID
    public let name: String
    public let rootPath: String
    public let projectIDs: [AirframeID]
    public let defaultProjectID: AirframeID?

    public init(
        id: AirframeID,
        name: String,
        rootPath: String,
        projectIDs: [AirframeID],
        defaultProjectID: AirframeID? = nil,
        metadata: AirframeCanonicalRecordMetadata = AirframeCanonicalRecordMetadata()
    ) {
        self.metadata = metadata
        self.id = id
        self.name = name
        self.rootPath = rootPath
        self.projectIDs = projectIDs
        self.defaultProjectID = defaultProjectID
    }
}

public struct AirframeCanonicalProjectRecord: Codable, Equatable, Sendable {
    public let metadata: AirframeCanonicalRecordMetadata
    public let id: AirframeID
    public let name: String
    public let repository: String
    public let activeEpicID: AirframeID?
    public let activeSprintID: AirframeID?
    public let epicIDs: [AirframeID]
    public let sprintIDs: [AirframeID]
    public let taskIDs: [AirframeID]
    public let issueIDs: [AirframeID]
    public let backendMappingIDs: [AirframeID]

    public init(
        id: AirframeID,
        name: String,
        repository: String,
        activeEpicID: AirframeID? = nil,
        activeSprintID: AirframeID? = nil,
        epicIDs: [AirframeID] = [],
        sprintIDs: [AirframeID] = [],
        taskIDs: [AirframeID] = [],
        issueIDs: [AirframeID] = [],
        backendMappingIDs: [AirframeID] = [],
        metadata: AirframeCanonicalRecordMetadata = AirframeCanonicalRecordMetadata()
    ) {
        self.metadata = metadata
        self.id = id
        self.name = name
        self.repository = repository
        self.activeEpicID = activeEpicID
        self.activeSprintID = activeSprintID
        self.epicIDs = epicIDs
        self.sprintIDs = sprintIDs
        self.taskIDs = taskIDs
        self.issueIDs = issueIDs
        self.backendMappingIDs = backendMappingIDs
    }
}

public struct AirframeCanonicalEpicRecord: Codable, Equatable, Sendable {
    public let metadata: AirframeCanonicalRecordMetadata
    public let workItem: AirframeWorkItem
    public let owner: String
    public let startDate: String?
    public let targetCloseDate: String?
    public let closeDate: String?
    public let goal: String
    public let rationale: String
    public let scope: [String]
    public let outOfScope: [String]
    public let acceptanceCriterionIDs: [AirframeID]
    public let sprintIDs: [AirframeID]
    public let taskIDs: [AirframeID]
    public let issueIDs: [AirframeID]
    public let planningDocumentPaths: [String]
    public let notes: [String]

    public init(
        workItem: AirframeWorkItem,
        owner: String,
        goal: String,
        rationale: String,
        startDate: String? = nil,
        targetCloseDate: String? = nil,
        closeDate: String? = nil,
        scope: [String] = [],
        outOfScope: [String] = [],
        acceptanceCriterionIDs: [AirframeID] = [],
        sprintIDs: [AirframeID] = [],
        taskIDs: [AirframeID] = [],
        issueIDs: [AirframeID] = [],
        planningDocumentPaths: [String] = [],
        notes: [String] = [],
        metadata: AirframeCanonicalRecordMetadata = AirframeCanonicalRecordMetadata()
    ) {
        self.metadata = metadata
        self.workItem = workItem
        self.owner = owner
        self.startDate = startDate
        self.targetCloseDate = targetCloseDate
        self.closeDate = closeDate
        self.goal = goal
        self.rationale = rationale
        self.scope = scope
        self.outOfScope = outOfScope
        self.acceptanceCriterionIDs = acceptanceCriterionIDs
        self.sprintIDs = sprintIDs
        self.taskIDs = taskIDs
        self.issueIDs = issueIDs
        self.planningDocumentPaths = planningDocumentPaths
        self.notes = notes
    }
}

public struct AirframeCanonicalSprintRecord: Codable, Equatable, Sendable {
    public let metadata: AirframeCanonicalRecordMetadata
    public let workItem: AirframeWorkItem
    public let epicID: AirframeID?
    public let goal: String
    public let startDate: String?
    public let endDate: String?
    public let capacity: String?
    public let taskIDs: [AirframeID]
    public let issueIDs: [AirframeID]
    public let notes: [String]

    public init(
        workItem: AirframeWorkItem,
        epicID: AirframeID?,
        goal: String,
        startDate: String? = nil,
        endDate: String? = nil,
        capacity: String? = nil,
        taskIDs: [AirframeID] = [],
        issueIDs: [AirframeID] = [],
        notes: [String] = [],
        metadata: AirframeCanonicalRecordMetadata = AirframeCanonicalRecordMetadata()
    ) {
        self.metadata = metadata
        self.workItem = workItem
        self.epicID = epicID
        self.goal = goal
        self.startDate = startDate
        self.endDate = endDate
        self.capacity = capacity
        self.taskIDs = taskIDs
        self.issueIDs = issueIDs
        self.notes = notes
    }
}

public struct AirframeCanonicalTaskRecord: Codable, Equatable, Sendable {
    public let metadata: AirframeCanonicalRecordMetadata
    public let workItem: AirframeWorkItem
    public let component: String
    public let priority: AirframeWorkPriority
    public let epicID: AirframeID?
    public let sprintID: AirframeID?
    public let dateRequested: String?
    public let dateImplemented: String?
    public let dateVerified: String?
    public let rationale: String
    public let currentBehavior: String?
    public let desiredBehavior: String?
    public let requirementIDs: [AirframeID]
    public let acceptanceCriteria: [String]
    public let designApproach: String?
    public let componentsAffected: [String]
    public let implementationDetails: String?
    public let evidenceIDs: [AirframeID]
    public let testSteps: [String]
    public let notes: [String]

    public init(
        workItem: AirframeWorkItem,
        component: String,
        priority: AirframeWorkPriority,
        rationale: String,
        epicID: AirframeID? = nil,
        sprintID: AirframeID? = nil,
        dateRequested: String? = nil,
        dateImplemented: String? = nil,
        dateVerified: String? = nil,
        currentBehavior: String? = nil,
        desiredBehavior: String? = nil,
        requirementIDs: [AirframeID] = [],
        acceptanceCriteria: [String] = [],
        designApproach: String? = nil,
        componentsAffected: [String] = [],
        implementationDetails: String? = nil,
        evidenceIDs: [AirframeID] = [],
        testSteps: [String] = [],
        notes: [String] = [],
        metadata: AirframeCanonicalRecordMetadata = AirframeCanonicalRecordMetadata()
    ) {
        self.metadata = metadata
        self.workItem = workItem
        self.component = component
        self.priority = priority
        self.epicID = epicID
        self.sprintID = sprintID
        self.dateRequested = dateRequested
        self.dateImplemented = dateImplemented
        self.dateVerified = dateVerified
        self.rationale = rationale
        self.currentBehavior = currentBehavior
        self.desiredBehavior = desiredBehavior
        self.requirementIDs = requirementIDs
        self.acceptanceCriteria = acceptanceCriteria
        self.designApproach = designApproach
        self.componentsAffected = componentsAffected
        self.implementationDetails = implementationDetails
        self.evidenceIDs = evidenceIDs
        self.testSteps = testSteps
        self.notes = notes
    }
}

public struct AirframeCanonicalIssueRecord: Codable, Equatable, Sendable {
    public let metadata: AirframeCanonicalRecordMetadata
    public let workItem: AirframeWorkItem
    public let severity: AirframeWorkPriority
    public let epicID: AirframeID?
    public let sprintID: AirframeID?
    public let dateReported: String?
    public let dateResolved: String?
    public let dateVerified: String?
    public let observedBehavior: String
    public let expectedBehavior: String
    public let reproductionSteps: [String]
    public let affectedComponents: [String]
    public let evidenceIDs: [AirframeID]
    public let notes: [String]

    public init(
        workItem: AirframeWorkItem,
        severity: AirframeWorkPriority,
        observedBehavior: String,
        expectedBehavior: String,
        epicID: AirframeID? = nil,
        sprintID: AirframeID? = nil,
        dateReported: String? = nil,
        dateResolved: String? = nil,
        dateVerified: String? = nil,
        reproductionSteps: [String] = [],
        affectedComponents: [String] = [],
        evidenceIDs: [AirframeID] = [],
        notes: [String] = [],
        metadata: AirframeCanonicalRecordMetadata = AirframeCanonicalRecordMetadata()
    ) {
        self.metadata = metadata
        self.workItem = workItem
        self.severity = severity
        self.epicID = epicID
        self.sprintID = sprintID
        self.dateReported = dateReported
        self.dateResolved = dateResolved
        self.dateVerified = dateVerified
        self.observedBehavior = observedBehavior
        self.expectedBehavior = expectedBehavior
        self.reproductionSteps = reproductionSteps
        self.affectedComponents = affectedComponents
        self.evidenceIDs = evidenceIDs
        self.notes = notes
    }
}

public struct AirframeCanonicalRequirementRecord: Codable, Equatable, Sendable {
    public let metadata: AirframeCanonicalRecordMetadata
    public let id: AirframeID
    public let externalID: String?
    public let title: String
    public let statement: String
    public let rationale: String
    public let sourceKind: AirframeRequirementSourceKind
    public let sourceURI: String?
    public let status: AirframeRequirementLifecycleStatus
    public let priority: AirframeWorkPriority
    public let verificationMethod: AirframeRequirementVerificationMethod
    public let validationRequired: Bool
    public let releaseScope: [String]
    public let parentIDs: [AirframeID]
    public let derivedFromIDs: [AirframeID]
    public let supersedesIDs: [AirframeID]
    public let traceLinks: [AirframeRequirementLink]
    public let deviationIDs: [AirframeID]
    public let currentRevisionID: AirframeID?
    public let changeRationale: String?

    public init(
        id: AirframeID,
        title: String,
        statement: String,
        status: AirframeRequirementLifecycleStatus,
        rationale: String = "",
        sourceKind: AirframeRequirementSourceKind = .airframe,
        sourceURI: String? = nil,
        externalID: String? = nil,
        priority: AirframeWorkPriority = .medium,
        verificationMethod: AirframeRequirementVerificationMethod = .test,
        validationRequired: Bool = true,
        releaseScope: [String] = [],
        parentIDs: [AirframeID] = [],
        derivedFromIDs: [AirframeID] = [],
        supersedesIDs: [AirframeID] = [],
        traceLinks: [AirframeRequirementLink] = [],
        deviationIDs: [AirframeID] = [],
        currentRevisionID: AirframeID? = nil,
        changeRationale: String? = nil,
        metadata: AirframeCanonicalRecordMetadata = AirframeCanonicalRecordMetadata()
    ) {
        self.metadata = metadata
        self.id = id
        self.externalID = externalID
        self.title = title
        self.statement = statement
        self.rationale = rationale
        self.sourceKind = sourceKind
        self.sourceURI = sourceURI
        self.status = status
        self.priority = priority
        self.verificationMethod = verificationMethod
        self.validationRequired = validationRequired
        self.releaseScope = releaseScope
        self.parentIDs = parentIDs
        self.derivedFromIDs = derivedFromIDs
        self.supersedesIDs = supersedesIDs
        self.traceLinks = traceLinks
        self.deviationIDs = deviationIDs
        self.currentRevisionID = currentRevisionID
        self.changeRationale = changeRationale
    }
}

public struct AirframeCanonicalRequirementRevisionRecord: Codable, Equatable, Sendable {
    public let metadata: AirframeCanonicalRecordMetadata
    public let id: AirframeID
    public let requirementID: AirframeID
    public let revisionNumber: Int
    public let title: String
    public let statement: String
    public let rationale: String
    public let sourceKind: AirframeRequirementSourceKind
    public let sourceURI: String?
    public let status: AirframeRequirementLifecycleStatus
    public let priority: AirframeWorkPriority
    public let verificationMethod: AirframeRequirementVerificationMethod
    public let validationRequired: Bool
    public let releaseScope: [String]
    public let parentIDs: [AirframeID]
    public let derivedFromIDs: [AirframeID]
    public let supersedesIDs: [AirframeID]
    public let traceLinks: [AirframeRequirementLink]
    public let deviationIDs: [AirframeID]
    public let changeRationale: String?

    public init(
        id: AirframeID,
        requirementID: AirframeID,
        revisionNumber: Int,
        title: String,
        statement: String,
        status: AirframeRequirementLifecycleStatus,
        rationale: String = "",
        sourceKind: AirframeRequirementSourceKind = .airframe,
        sourceURI: String? = nil,
        priority: AirframeWorkPriority = .medium,
        verificationMethod: AirframeRequirementVerificationMethod = .test,
        validationRequired: Bool = true,
        releaseScope: [String] = [],
        parentIDs: [AirframeID] = [],
        derivedFromIDs: [AirframeID] = [],
        supersedesIDs: [AirframeID] = [],
        traceLinks: [AirframeRequirementLink] = [],
        deviationIDs: [AirframeID] = [],
        changeRationale: String? = nil,
        metadata: AirframeCanonicalRecordMetadata = AirframeCanonicalRecordMetadata()
    ) {
        self.metadata = metadata
        self.id = id
        self.requirementID = requirementID
        self.revisionNumber = revisionNumber
        self.title = title
        self.statement = statement
        self.rationale = rationale
        self.sourceKind = sourceKind
        self.sourceURI = sourceURI
        self.status = status
        self.priority = priority
        self.verificationMethod = verificationMethod
        self.validationRequired = validationRequired
        self.releaseScope = releaseScope
        self.parentIDs = parentIDs
        self.derivedFromIDs = derivedFromIDs
        self.supersedesIDs = supersedesIDs
        self.traceLinks = traceLinks
        self.deviationIDs = deviationIDs
        self.changeRationale = changeRationale
    }
}

public struct AirframeCanonicalAcceptanceCriterionRecord: Codable, Equatable, Sendable {
    public let metadata: AirframeCanonicalRecordMetadata
    public let id: AirframeID
    public let ownerID: AirframeID
    public let text: String
    public let isVerified: Bool
    public let evidenceIDs: [AirframeID]

    public init(
        id: AirframeID,
        ownerID: AirframeID,
        text: String,
        isVerified: Bool = false,
        evidenceIDs: [AirframeID] = [],
        metadata: AirframeCanonicalRecordMetadata = AirframeCanonicalRecordMetadata()
    ) {
        self.metadata = metadata
        self.id = id
        self.ownerID = ownerID
        self.text = text
        self.isVerified = isVerified
        self.evidenceIDs = evidenceIDs
    }
}

public enum AirframeCanonicalEvidenceResult: String, Codable, Equatable, Sendable {
    case passed
    case failed
    case notRun
    case informational
}

public struct AirframeCanonicalEvidenceSummaryRecord: Codable, Equatable, Sendable {
    public let metadata: AirframeCanonicalRecordMetadata
    public let id: AirframeID
    public let workItemIDs: [AirframeID]
    public let requirementIDs: [AirframeID]
    public let summary: String
    public let command: String?
    public let result: AirframeCanonicalEvidenceResult
    public let artifactReferences: [String]
    public let ciReferences: [String]
    public let environment: String?

    public init(
        id: AirframeID,
        workItemIDs: [AirframeID],
        summary: String,
        result: AirframeCanonicalEvidenceResult,
        requirementIDs: [AirframeID] = [],
        command: String? = nil,
        artifactReferences: [String] = [],
        ciReferences: [String] = [],
        environment: String? = nil,
        metadata: AirframeCanonicalRecordMetadata = AirframeCanonicalRecordMetadata()
    ) {
        self.metadata = metadata
        self.id = id
        self.workItemIDs = workItemIDs
        self.requirementIDs = requirementIDs
        self.summary = summary
        self.command = command
        self.result = result
        self.artifactReferences = artifactReferences
        self.ciReferences = ciReferences
        self.environment = environment
    }
}

public struct AirframeCanonicalAuditEventRecord: Codable, Equatable, Sendable {
    public let metadata: AirframeCanonicalRecordMetadata
    public let event: AirframeAuditEvent
    public let beforeRecordID: AirframeID?
    public let afterRecordID: AirframeID?

    public init(
        event: AirframeAuditEvent,
        beforeRecordID: AirframeID? = nil,
        afterRecordID: AirframeID? = nil,
        metadata: AirframeCanonicalRecordMetadata = AirframeCanonicalRecordMetadata()
    ) {
        self.metadata = metadata
        self.event = event
        self.beforeRecordID = beforeRecordID
        self.afterRecordID = afterRecordID
    }
}

public struct AirframeCanonicalBackendMappingRecord: Codable, Equatable, Sendable {
    public let metadata: AirframeCanonicalRecordMetadata
    public let id: AirframeID
    public let localRecordID: AirframeID
    public let backendKind: String
    public let externalID: String
    public let externalURL: String?

    public init(
        id: AirframeID,
        localRecordID: AirframeID,
        backendKind: String,
        externalID: String,
        externalURL: String? = nil,
        metadata: AirframeCanonicalRecordMetadata = AirframeCanonicalRecordMetadata()
    ) {
        self.metadata = metadata
        self.id = id
        self.localRecordID = localRecordID
        self.backendKind = backendKind
        self.externalID = externalID
        self.externalURL = externalURL
    }
}

public struct AirframeCanonicalWorkflowDefinitionRecord: Codable, Equatable, Sendable {
    public let metadata: AirframeCanonicalRecordMetadata
    public let id: AirframeID
    public let workItemKind: AirframeWorkItemKind
    public let allowedStatuses: [AirframeWorkStatus]
    public let transitionIDs: [AirframeID]

    public init(
        id: AirframeID,
        workItemKind: AirframeWorkItemKind,
        allowedStatuses: [AirframeWorkStatus],
        transitionIDs: [AirframeID],
        metadata: AirframeCanonicalRecordMetadata = AirframeCanonicalRecordMetadata()
    ) {
        self.metadata = metadata
        self.id = id
        self.workItemKind = workItemKind
        self.allowedStatuses = allowedStatuses
        self.transitionIDs = transitionIDs
    }
}

public struct AirframeCanonicalWorkflowTransitionRecord: Codable, Equatable, Sendable {
    public let metadata: AirframeCanonicalRecordMetadata
    public let id: AirframeID
    public let workItemKind: AirframeWorkItemKind
    public let fromStatus: AirframeWorkStatus
    public let toStatus: AirframeWorkStatus
    public let operation: AirframeOperation
    public let requiredAuthorityClasses: [AirframeAuthorityClass]
    public let preconditions: [String]
    public let sideEffects: [String]
    public let auditRequired: Bool

    public init(
        id: AirframeID,
        workItemKind: AirframeWorkItemKind,
        fromStatus: AirframeWorkStatus,
        toStatus: AirframeWorkStatus,
        operation: AirframeOperation,
        requiredAuthorityClasses: [AirframeAuthorityClass],
        preconditions: [String] = [],
        sideEffects: [String] = [],
        auditRequired: Bool = true,
        metadata: AirframeCanonicalRecordMetadata = AirframeCanonicalRecordMetadata()
    ) {
        self.metadata = metadata
        self.id = id
        self.workItemKind = workItemKind
        self.fromStatus = fromStatus
        self.toStatus = toStatus
        self.operation = operation
        self.requiredAuthorityClasses = requiredAuthorityClasses
        self.preconditions = preconditions
        self.sideEffects = sideEffects
        self.auditRequired = auditRequired
    }
}
