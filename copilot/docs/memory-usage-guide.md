# Using Your Memory Effectively

> **TL;DR:** Search before retrieving the full graph, use consistent entity patterns, add observations incrementally, and update memory in real-time.

## Contents
- [Core Principles](#core-principles)
- [Memory Retrieval Workflow](#memory-retrieval-workflow)
- [Memory Creation Best Practices](#memory-creation-best-practices)
- [Memory Maintenance Strategies](#memory-maintenance-strategies)
- [Common Memory Patterns](#common-memory-patterns)

## Core Principles

- Use targeted searches before broad memory retrieval
- Keep entities and observations focused and well-structured
- Maintain consistent naming and relationship patterns
- Update memory in real-time as you discover new information
- Prioritize linking entities over creating monolithic observations

## Memory Retrieval Workflow

1. **Start with targeted search**:

   ```text
   9f1_search_nodes(query: "ktsu.dev")
   ```

2. **Examine specific entities** when you know what you need:

   ```text
   9f1_open_nodes(names: ["AppDataStorage", "ImGuiWidgets"])
   ```

3. **Fall back to full graph** only when necessary:

   ```text
   9f1_read_graph()
   ```

## Memory Creation Best Practices

- **Define clear entity hierarchies**:

  ```text
  9f1_create_entities(entities: [
    { "name": "ktsu.dev", "entityType": "Project", "observations": ["Collection of .NET libraries"] },
    { "name": "AppDataStorage", "entityType": "Library", "observations": ["Part of ktsu.dev"] }
  ])

  9f1_create_relations(relations: [
    { "from": "AppDataStorage", "relationType": "partOf", "to": "ktsu.dev" }
  ])
  ```

- **Use consistent observation formats**:

  ```text
  9f1_add_observations(observations: [{
    "entityName": "AppDataStorage",
    "contents": [
      "Purpose: Simplifies storing application configuration data",
      "Features: JSON serialization, automatic backup, path management",
      "Latest Version: 1.2.0 as of April 2025"
    ]
  }])
  ```

- **Update observations incrementally** as you learn more:

  ```text
  9f1_add_observations(observations: [{
    "entityName": "AppDataStorage",
    "contents": ["New in v1.2.0: Added support for encrypted storage"]
  }])
  ```

## Memory Maintenance Strategies

- **Run organization script periodically**:

  ```powershell
  cd .github/copilot
  ./organize_memory.ps1
  ```

- **Review entity consistency** to ensure proper naming and typing
- **Consolidate fragmented information** through thoughtful entity design
- **Establish standardized relation types** (for a comprehensive list, see [Memory Standardization Guidelines](memory-standardization-guidelines.md))
- **Split large entities** when they cover multiple distinct concepts

## Common Memory Patterns

### Library Documentation

```text
// Create the library entity
9f1_create_entities(entities: [{
  "name": "StrongPaths",
  "entityType": "Library",
  "observations": [
    "Purpose: Type-safe file and directory path manipulation",
    "Latest Version: 2.1.0 (April 2025)",
    "Repository: ktsu-dev/StrongPaths"
  ]
}])

// Create related concept entities
9f1_create_entities(entities: [{
  "name": "Path Safety",
  "entityType": "Concept",
  "observations": [
    "Preventing path-related errors through strong typing",
    "Compile-time validation of path operations"
  ]
}])

// Link with appropriate relations
9f1_create_relations(relations: [
  { "from": "StrongPaths", "relationType": "implements", "to": "Path Safety" },
  { "from": "StrongPaths", "relationType": "partOf", "to": "ktsu.dev" }
])
```

### Feature Documentation

```text
// Document a feature with its components
9f1_create_entities(entities: [{
  "name": "StrongPaths.PathConversion",
  "entityType": "Feature",
  "observations": [
    "Purpose: Convert between different path types",
    "Implemented via extension method pattern",
    "Supports all path type conversions"
  ]
}])

// Link to parent library
9f1_create_relations(relations: [{
  "from": "StrongPaths.PathConversion",
  "relationType": "partOf",
  "to": "StrongPaths"
}])
```

### Code Pattern Documentation

```text
// Document a pattern used across libraries
9f1_create_entities(entities: [{
  "name": "Extension Method Safety Pattern",
  "entityType": "Pattern",
  "observations": [
    "Purpose: Provide type-safe operations through extension methods",
    "Implements fluent API design for method chaining",
    "Used across multiple ktsu.dev libraries"
  ]
}])

// Link libraries using this pattern
9f1_create_relations(relations: [
  { "from": "StrongPaths", "relationType": "uses", "to": "Extension Method Safety Pattern" },
  { "from": "AppDataStorage", "relationType": "uses", "to": "Extension Method Safety Pattern" }
])
```

---

*Previous: [Memory Tools Reference](memory-tools-reference.md) | Next: [Memory Standardization Guidelines](memory-standardization-guidelines.md)*
