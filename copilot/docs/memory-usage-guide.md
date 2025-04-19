# Using Your Memory Effectively

## Core Principles

- Use targeted searches before broad memory retrieval
- Keep entities and observations focused and well-structured
- Maintain consistent naming and relationship patterns
- Update memory in real-time as you discover new information

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
    { "from": "AppDataStorage", "relationType": "isPartOf", "to": "ktsu.dev" }
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

## Related Resources

- [Memory Tools Reference](memory-tools-reference.md) - Tool usage and examples
- [Memory Standardization Guidelines](memory-standardization-guidelines.md) - Comprehensive standardization guide
- [Project Memory Organization](project-memory-organization.md) - Entity structure overview
- [Unknown Information Management](unknown-info-management.md) - Handling missing information

[Back to Main Instructions](main-instructions.md)
