# Memory Standardization Guidelines

This guide provides comprehensive standards for organizing and maintaining memory entities in your project knowledge graph. Following these guidelines will help ensure consistency and maximize the effectiveness of your project memory.

## Entity Structure Standards

### Naming Conventions

- Use clear, descriptive names that reflect the entity's purpose
- Maintain consistent capitalization patterns (typically PascalCase for code elements)
- Use prefixes for related entity groups (e.g., `UI.Button`, `UI.Panel`)
- Include version numbers when tracking evolving components
- Avoid abbreviations unless they're standard in the domain

### Entity Type Selection

Use these standard entity types to categorize your memories appropriately:

- "Command" - CLI commands, operations, or actions
- "Class" - Code classes and their relationships
- "Function" - Important functions or methods
- "Pattern" - Design patterns in the codebase
- "Code Structure" - Architectural elements
- "Technology Stack" - Technologies, frameworks, libraries
- "Project" - Overall project information
- "Concept" - High-level domain concepts
- "User" - User roles, personas, or profiles
- "Developer" - Developer roles, personas, or profiles
- "Task" - Tasks a user or developer could perform
- "Challenge" - Challenges faced in the project
- "Goal" - Goals or objectives to achieve
- "Requirement" - Requirements for the project
- "User Story" - User stories describing features
- "Feature" - Project or product features
- "Library" - Software libraries or packages
- "Tool" - Tools used in the project
- "Framework" - Frameworks used in the project
- "Component" - Individual parts of the project
- "Module" - Modules or packages in the project
- "Service" - Services used in the project
- "API" - APIs used in the project
- "Endpoint" - API endpoints
- "Database" - Databases used in the project
- "Schema" - Database schemas or structures
- "Entity" - General entities in the project knowledge graph
- "Relationship" - Relationships between entities in the project knowledge graph
- "Observation" - Observations or notes about entities
- "Link" - Links between entities in the project knowledge graph
- "Note" - Important notes or annotations related to entities
- "Reference" - References to external resources or documentation
- "Resource" - Resources related to the project
- "Documentation" - Documentation related to the project
- "Specification" - Specifications for the project
- "Standard" - Standards and best practices for the project
- "Guideline" - Guidelines for the project
- "Policy" - Policies related to the project
- "Procedure" - Procedures related to the project
- "Process" - Processes related to the project
- "Workflow" - Workflows related to the project
- "Template" - Templates used in the project
- "Example" - Examples related to the project
- "Sample" - Sample code or data related to the project
- "Test" - Tests related to the project

### Observation Format Standards

Format observations consistently for improved searchability and readability:

- Use concise, factual statements
- Start with action verbs or key nouns
- Include version information where applicable
- Structure multi-part observations with clear separators:

  ```text
  "Purpose: Simplifies configuration persistence",
  "Features: JSON serialization, automatic backup",
  "Version: 1.2.0 (April 2023)"
  ```

- Group related information in single observations
- Use consistent terminology across similar entities

## Relationship Standardization

### Relation Type Standards

Use these standardized relation types for consistent relationship modeling:

#### Core Relationships

- `dependsOn` - For dependencies
- `partOf` - For component hierarchies
- `uses` - For utility relationships
- `extends` - For inheritance relationships
- `relatedTo` - For general relationships
- `interactsWith` - For interaction relationships
- `defines` - For defining relationships
- `describes` - For descriptive relationships
- `definedBy` - For defining relationships
- `describedBy` - For descriptive relationships
- `isA` - For type relationships
- `hasA` - For composition relationships
- `hasMany` - For collection relationships

#### Project-Specific Relationships

- `buildsOn` - For project-specific relationships
- `addresses` - For solutions to problems
- `complements` - For complementary features
- `advocatesFor` - For recommended practices

#### Ownership Relationships

- `contains` - For collections of items
- `has` - For properties of entities
- `is` - For defining types or categories

#### Creation Relationships

- `createdBy` - For authorship relationships
- `created` - For creation relationships
- `createdOn` - For creation dates

#### Distribution Relationships

- `distributes` - For distribution relationships
- `distributedBy` - For distribution authorship
- `distributedOn` - For distribution dates
- `publishes` - For publishing relationships
- `publishedBy` - For publishing relationships
- `publishedOn` - For publication dates
- `releases` - For release relationships
- `releasedBy` - For release relationships
- `releasedOn` - For release dates

#### Feature Relationships

- `enables` - For enabling features
- `enabledBy` - For dependencies enabling features

#### Issue Relationships

- `resolves` - For resolving issues
- `resolvedBy` - For dependencies resolving issues
- `prevents` - For preventing issues
- `preventedBy` - For dependencies preventing issues
- `causes` - For causing issues
- `causedBy` - For dependencies causing issues

#### Sequence Relationships

- `precedes` - For preceding relationships
- `succeeds` - For succeeding relationships
- `causes` - For causing issues
- `causedBy` - For dependencies causing issues

#### Implementation Relationships

- `implements` - For implementation relationships
- `implementedBy` - For implementation relationships
- `implementedOn` - For implementation dates

#### Deprecation Relationships

- `deprecated` - For deprecated features
- `replacedBy` - For replaced features
- `deprecatedOn` - For deprecation dates
- `replacedOn` - For replacement dates
- `deprecatedBy` - For deprecating practices
- `deprecates` - For practices deprecating others

#### Licensing Relationships

- `licensedUnder` - For licensing relationships
- `licensedBy` - For license authorship
- `licensedTo` - For license recipients
- `licensedFor` - For licensing purposes
- `licensedAs` - For licensing formats
- `licensedOn` - For licensing dates

#### Usage Relationships

- `usedBy` - For usage relationships
- `usedOn` - For usage dates
- `usedAfter` - For sequential usage
- `usedBefore` - For sequential usage
- `usedDuring` - For temporal usage
- `usedIn` - For contextual usage
- `usedWith` - For complementary usage
- `usedAgainst` - For opposing usage
- `usedFor` - For purposeful usage
- `usedAlongside` - For parallel usage
- `usedInsteadOf` - For alternative usage

#### Preference Relationships

- `preferredBy` - For preferred tools/practices
- `preferredOver` - For preferred alternatives
- `recommends` - For recommending practices
- `recommendedBy` - For recommended practices
- `recommendsOver` - For recommended alternatives
- `recommendsAgainst` - For discouraged practices
- `unpreferredBy` - For unpreferred practices
- `unpreferredOver` - For unpreferred alternatives

#### Hierarchical Relationships

- `parentOf` - For parent-child relationships
- `childOf` - For child-parent relationships
- `siblingOf` - For sibling relationships
- `ancestorOf` - For ancestral relationships
- `descendantOf` - For descendant relationships
- `predecessorOf` - For predecessor relationships
- `successorOf` - For successor relationships

#### Similarity Relationships

- `similarTo` - For similar relationships
- `dissimilarTo` - For dissimilar relationships

#### Support Relationships

- `supports` - For supporting relationships
- `supportedBy` - For supported relationships
- `supportedOn` - For support dates

#### Integration Relationships

- `integrates` - For integration relationships
- `integratedBy` - For integrated relationships
- `integratedOn` - For integration dates

#### Wrapper Relationships

- `wraps` - For wrapping relationships
- `wrappedBy` - For wrapped relationships
- `wrappedOn` - For wrapping dates

### Relationship Direction Standards

- Be consistent with relationship direction:
  - Subject → Relationship → Object
  - From entity is typically the more specific concept
  - To entity is typically the more general concept
- Use active voice in relationship naming
- Ensure relationships form a connected graph without isolated nodes
- Ensure relationships are bidirectional where applicable

## Memory Organization Strategies

### Entity Grouping Standards

- Group related entities using consistent naming patterns
- Use hierarchical organization for complex domains
- Create index entities for important categories
- Use relation types to express natural taxonomies
- Maintain balanced entity granularity (not too broad or narrow)

### Content Organization Standards

- Place fundamental concepts at the top level
- Group implementation details under corresponding concepts
- Keep related entities connected via explicit relationships
- Use "Gateway" entities to connect disparate domains
