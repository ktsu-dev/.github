# Memory Standardization Guidelines

This guide provides comprehensive standards for organizing and maintaining knowledge in your Zettelkasten-based project memory. Following these guidelines will help ensure consistency and maximize the effectiveness of your knowledge network.

## Zettelkasten Core Principles

### Atomicity
- Each note should contain exactly one idea or concept
- Keep notes focused and concise (typically 250-500 words)
- Break down complex topics into multiple interconnected notes
- Title notes based on their specific content, not general categories

### Connectivity
- No note is an island—create meaningful connections between related ideas
- Use semantic link types to express the nature of relationships
- Build a densely connected knowledge graph to facilitate discovery
- Consider both incoming and outgoing links for each note

### Emergence
- Let new insights and patterns emerge from connections between notes
- Regularly review and refine your note network
- Create structure notes to map conceptual territories
- Use links to build knowledge paths through related concepts

## Note Creation Standards

### Content Structure
- Start with a clear, descriptive title that captures the core concept
- Begin the note with a concise definition or summary
- Use markdown formatting for readability and structure:
  - Headers for logical sections (`##`, `###`)
  - Lists for related items or steps
  - Code blocks for technical content
  - Emphasis for important points
- End with potential connections to explore further
- Use Zettelkasten-specific guidelines to enhance note connectivity and discovery:
  - Create meaningful links to related notes
  - Use link types to express the nature of relationships
  - Regularly review and refine your note network

### Metadata Standards
- Use consistent YAML frontmatter for note metadata:
  ```yaml
  ---
  id: [auto-generated timestamp ID]
  title: "Concise, specific title"
  note_type: [permanent|literature|fleeting|structure|hub]
  tags: tag1, tag2, tag3
  created: YYYY-MM-DD
  modified: YYYY-MM-DD
  ---
  ```
- Choose note type deliberately based on content purpose:
  - **Permanent notes**: Well-formulated, evergreen ideas
  - **Literature notes**: Notes from reading material
  - **Fleeting notes**: Quick, temporary captures for processing
  - **Structure notes**: Index or outline notes organizing concepts
  - **Hub notes**: Entry points to key topic areas

### Tagging Standards
- Use specific, descriptive tags (prefer `functional-programming` over `programming`)
- Apply consistent plurality (singular preferred)
- Create tag hierarchies with hyphens (`language-python` vs `language-javascript`)
- Limit to 3-7 most relevant tags per note
- Maintain a controlled vocabulary for core project concepts

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

### Zettelkasten Link Type System

The Zettelkasten system uses seven primary link types that express semantic relationships between notes. Each link type has a specific purpose and can have a corresponding inverse relationship:

| Link Type | Inverse Link Type | Relationship Description |
|-----------|------------------|--------------------------|
| `reference` | `reference` | Simple reference to related information (symmetric) |
| `extends` | `extended_by` | One note builds upon or develops concepts from another |
| `refines` | `refined_by` | One note clarifies or improves upon another |
| `contradicts` | `contradicted_by` | One note presents opposing views to another |
| `questions` | `questioned_by` | One note poses questions about another |
| `supports` | `supported_by` | One note provides evidence for another |
| `related` | `related` | Generic relationship (symmetric) |

### Relationship Mapping to Zettelkasten Links

To standardize relationships in your knowledge system, map your conceptual relationships to these seven link types:

#### 1. `extends` / `extended_by` Relationships

Use for hierarchical, developmental, and "builds upon" relationships:

| Domain Relationship | Direction | Usage Context |
|--------------------|-----------|---------------|
| `extends` | Direct | Code/class inheritance |
| `partOf` | Part → Whole | Component hierarchies |
| `buildsOn` | Building → Foundation | Development of ideas |
| `isA` | Specific → General | Type relationships |
| `childOf` | Child → Parent | Hierarchical relationships |
| `contains` | Container → Contained | Containment relationships |
| `integrates` | Integration → Integrated | Integration patterns |
| `created` | Creator → Creation | Creation relationships |

**Examples:**
- "TypeScript" `extends` "JavaScript"
- "Factory Method Pattern" `extends` "Creational Patterns"
- "Project Requirements" `extended_by` "Technical Specifications"

#### 2. `refines` / `refined_by` Relationships

Use for clarification, improvement, and definition relationships:

| Domain Relationship | Direction | Usage Context |
|--------------------|-----------|---------------|
| `defines` | Definition → Concept | Definitional relationships |
| `addresses` | Solution → Problem | Problem-solving relationships |
| `definedBy` | Concept → Definition | Inverse definitional relationships |
| `refines` | Refinement → Base | Improvement relationships |

**Examples:**
- "Unit Testing Best Practices" `refines` "Software Testing Principles"
- "Code Review Standards" `refines` "Quality Assurance Process"
- "Domain-Specific Language" `refined_by` "Language Implementation Details"

#### 3. `supports` / `supported_by` Relationships

Use for evidence, dependency, and reinforcement relationships:

| Domain Relationship | Direction | Usage Context |
|--------------------|-----------|---------------|
| `supports` | Evidence → Claim | Supporting evidence |
| `supportedBy` | Claim → Evidence | Evidence backing |
| `dependsOn` | Dependent → Dependency | Dependency relationships |
| `complements` | Complementary → Primary | Enhancement relationships |
| `advocatesFor` | Advocate → Advocated | Advocacy relationships |
| `answers` | Answer → Question | Answer relationships |

**Examples:**
- "Performance Metrics" `supports` "Architectural Decisions"
- "Research Findings" `supports` "Design Choices"
- "Implementation Strategy" `supported_by` "Academic Papers"

#### 4. `contradicts` / `contradicted_by` Relationships

Use for opposing viewpoints and contrasting relationships:

| Domain Relationship | Direction | Usage Context |
|--------------------|-----------|---------------|
| `contradicts` | Contradiction → Contradicted | Opposing views |
| `dissimilarTo` | Contrasting → Contrasted | Contrasting approaches |
| `usedAgainst` | Argument → Countered | Counterarguments |

**Examples:**
- "Immutable Architecture" `contradicts` "State-Based Design"
- "Microservices Benefits" `contradicted_by` "Operational Complexity Concerns"
- "Functional Programming" `contradicts` "Imperative Programming Paradigms"

#### 5. `questions` / `questioned_by` Relationships

Use for inquiry, doubt, and examination relationships:

| Domain Relationship | Direction | Usage Context |
|--------------------|-----------|---------------|
| `questions` | Question → Subject | Inquiry relationships |
| `challengesAssumptionsOf` | Challenge → Assumption | Critical examination |

**Examples:**
- "Security Analysis" `questions` "Authentication Implementation"
- "Performance Research" `questions` "Architectural Approach"
- "Edge Case Scenarios" `questions` "General Solutions"

#### 6. `reference` Relationships

Use for general references and documentation relationships:

| Domain Relationship | Direction | Usage Context |
|--------------------|-----------|---------------|
| `uses` | User → Used | Usage relationships |
| `describes` | Description → Subject | Documentation relationships |
| `describedBy` | Subject → Description | Documentation references |
| `implementedBy` | Interface → Implementation | Implementation references |

**Examples:**
- "API Documentation" `reference` "Function Specifications"
- "Code Examples" `reference` "Design Patterns"
- "Release Notes" `reference` "Feature Implementations"

#### 7. `related` Relationships

Use for general thematic connections when more specific relationships don't apply:

| Domain Relationship | Direction | Usage Context |
|--------------------|-----------|---------------|
| `relatedTo` | Any | General connections |
| `interactsWith` | Interactor → Interacted | Interaction relationships |
| `similarTo` | Similar A → Similar B | Similarity relationships |
| `siblingOf` | Sibling A → Sibling B | Parallel relationships |

**Examples:**
- "Frontend Development" `related` "UX Design Principles"
- "Database Migration" `related` "Data Integrity Checks"
- "DevOps Practices" `related` "Continuous Deployment"

### Relationship Direction Standards in Zettelkasten

- Follow consistent directional semantics based on the link type:
  - Source note → Link Type → Target note
  - For `extends`/`extended_by`: The more specific concept extends the more general one
  - For `refines`/`refined_by`: The refinement points to what is being refined
  - For `supports`/`supported_by`: The supporting evidence points to the supported claim
  - For `contradicts`/`contradicted_by`: The contradiction points to what is being contradicted
  - For `questions`/`questioned_by`: The inquiry points to what is being questioned
- Consider bidirectional links for relationships that benefit from both perspectives
- Maintain semantic consistency through appropriate link type selection
- Structure link networks to facilitate knowledge discovery and emergence

### Note Linking Best Practices

#### When to Create Links vs. New Notes

- Create a new note when:
  - A concept deserves standalone exploration (atomicity principle)
  - You need to develop an idea beyond a paragraph
  - A concept will likely connect to multiple other notes
  - The information represents a distinct, reusable unit of knowledge

- Create a link when:
  - Two existing concepts have a meaningful relationship
  - One note builds upon, refines, or questions another
  - You want to establish a connection for future exploration
  - Creating a knowledge path through related ideas

#### Link Creation Guidelines

- Prefer specific link types over generic ones (`refines` instead of `related`)
- Add meaningful descriptions to links to explain the relationship nuance
- Create "hub" notes with multiple outgoing links for important concepts
- Review existing links periodically to maintain knowledge graph coherence
- Consider the future discovery path: how will you want to rediscover this connection?

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
