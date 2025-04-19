# Memory Tools Reference

Your memory is managed by the `mcp-knowledge-graph` server, which provides these tools:

## Reading Tools

- `search_nodes` - Query for memories related to specific search terms or keywords, prefer searching for single keywords because it searches content for the exact match
- `open_nodes` - Access specific entities by their exact name
- `read_graph` - Access the entire memory graph for a comprehensive project overview

## Writing Tools

- `add_observations` - Add observations to existing entities. You should attempt to add observations first and only create new entities if `add_observations` fails to find an existing entity
- `create_entities` - Create new entities in your memory, including properties and observations. You should attempt to add observations first and only create new entities if `add_observations` fails to find an existing entity
- `create_relations` - Create relationships between entities

## Maintenance Tools

- `delete_entities` - Remove entities from your memory
- `delete_relations` - Remove relationships between entities
- `delete_observations` - Remove specific observations from entities

## Memory Organization Script

The `.github/copilot/organize_memory.ps1` PowerShell script helps maintain memory organization by:

- Creating timestamped backups before changes
- Sorting entities by logical type groups
- Arranging properties in consistent order
- Organizing relations after entities

## Tool Selection Strategy

- Use `search_nodes` first when looking for specific information. It searches for keywords in the content of entities and is the most efficient way to find information. Prefer searching for single keywords because it searches content for the exact match. For example:

  ```text
  9f1_search_nodes(query: "AppDataStorage")
  ```

- Use `open_nodes` when you know exactly which entity you need. You can supply a list of entity names to open multiple entities at once. For example:

  ```text
  9f1_open_nodes(names: ["AppDataStorage", "ImGuiWidgets"])
  ```

- Use `read_graph` only when targeted searches fail or you need complete context. It provides a comprehensive overview of all entities and their relationships in your memory.
  
  ```text
  9f1_read_graph()
  ```

- When adding information, use appropriate entity types:

  ```text
  9f1_create_entities(entities: [{
    "name": "AppDataStorage",
    "entityType": "Library",
    "observations": ["Simplifies application configuration persistence"]
  }])
  ```

- Use `add_observations` to update existing entities:

  ```text
  9f1_add_observations(observations: [{
    "entityName": "AppDataStorage",
    "contents": ["Supports automatic backup of old files"]
  }])
  ```

- Create meaningful relationships:

  ```text
  9f1_create_relations(relations: [{
    "from": "AppDataStorage",
    "relationType": "implements",
    "to": "JSON Serialization"
  }])
  ```

## Memory Organization Best Practices

- **Consistent Naming**: Use consistent naming conventions for easier searching
- **Logical Grouping**: Group related entities with common prefixes or entity types
- **Property Ordering**: Maintain consistent property order (type, name, entityType, observations)
- **Regular Maintenance**: Run the organize_memory.ps1 script periodically
- **Backup Before Changes**: Always create backups before bulk modifications
- **Entity Hierarchy**: Establish clear hierarchical relationships using appropriate relation types
- **Avoid Duplication**: Check for existing entities before creating new ones

> Note: Tool names may be prefixed with characters (e.g., "9f1_"). Match the name with available tools and ask for clarification if needed.

[Back to Main Instructions](main-instructions.md)
