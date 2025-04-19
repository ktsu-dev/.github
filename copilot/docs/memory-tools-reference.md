# Memory Tools Reference

> **TL;DR:** Start with `search_nodes` for targeted lookups, use `open_nodes` for known entities, and only fall back to `read_graph` when necessary.

Your memory is managed by the `mcp-knowledge-graph` server, which provides these tools:

## Contents
- [Reading Tools](#reading-tools)
- [Writing Tools](#writing-tools)
- [Maintenance Tools](#maintenance-tools)
- [Tool Selection Strategy](#tool-selection-strategy)
- [Memory Organization Best Practices](#memory-organization-best-practices)

## Reading Tools

| Tool | Purpose | Example |
|------|---------|---------|
| `search_nodes` | Find entities by keyword | `9f1_search_nodes(query: "AppDataStorage")` |
| `open_nodes` | Access specific entities | `9f1_open_nodes(names: ["AppDataStorage", "ImGuiWidgets"])` |
| `read_graph` | View entire memory graph | `9f1_read_graph()` |

**When to use each tool:**
- **search_nodes**: Use first for any information lookup (searches entity content)
- **open_nodes**: Use when you know exact entity names
- **read_graph**: Use only when other methods fail or you need full context

## Writing Tools

| Tool | Purpose | Example |
|------|---------|---------|
| `add_observations` | Update existing entities | `9f1_add_observations(observations: [{"entityName": "AppDataStorage", "contents": ["New feature: encryption"]}])` |
| `create_entities` | Add new entities | `9f1_create_entities(entities: [{"name": "AppDataStorage", "entityType": "Library", "observations": ["Configuration persistence"]}])` |
| `create_relations` | Link related entities | `9f1_create_relations(relations: [{"from": "AppDataStorage", "relationType": "implements", "to": "JSON Serialization"}])` |

**When to use each tool:**
- **add_observations**: Always try this first before creating new entities
- **create_entities**: Create new entities only when they don't already exist
- **create_relations**: Create meaningful connections between entities

**Important Note About create_entities**:
- The `create_entities` tool returns a list of successfully created entities
- If an entity you intended to create is not included in the response, it means that entity already exists in memory
- Existing entities are not updated by `create_entities` - use `add_observations` for those instead
- Best practice: Try `add_observations` first; if it fails with an entity not found error, then use `create_entities`

## Maintenance Tools

| Tool | Purpose | Example |
|------|---------|---------|
| `delete_entities` | Remove entities | `9f1_delete_entities(entityNames: ["DuplicateEntity"])` |
| `delete_relations` | Remove relationships | `9f1_delete_relations(relations: [{"from": "EntityA", "relationType": "incorrect", "to": "EntityB"}])` |
| `delete_observations` | Remove observations | `9f1_delete_observations(deletions: [{"entityName": "Entity", "observations": ["Outdated info"]}])` |

**Organization Script:**

The `.github/copilot/organize_memory.ps1` PowerShell script helps maintain memory organization:

```powershell
cd .github/copilot
./organize_memory.ps1
```

This script automatically:
- Creates timestamped backups before changes
- Sorts entities by logical type groups
- Arranges properties in consistent order
- Organizes relations after entities

## Tool Selection Strategy

### Information Lookup Workflow

1. **Start with targeted search**:
   ```text
   9f1_search_nodes(query: "AppDataStorage")
   ```

2. **If targeted search doesn't find what you need**, try viewing specific entities:
   ```text
   9f1_open_nodes(names: ["AppDataStorage", "ImGuiWidgets"])
   ```

3. **Only as a last resort**, view the entire graph:
   ```text
   9f1_read_graph()
   ```

### Information Creation Workflow

1. **First check if entity exists**:
   ```text
   9f1_search_nodes(query: "EntityName")
   ```

2. **Try adding observations first** (will fail if entity doesn't exist):
   ```text
   9f1_add_observations(observations: [{
     "entityName": "AppDataStorage",
     "contents": ["Supports automatic backup of old files"]
   }])
   ```

3. **If add_observations fails, create the entity**:
   ```text
   9f1_create_entities(entities: [{
     "name": "AppDataStorage",
     "entityType": "Library",
     "observations": ["Simplifies application configuration persistence"]
   }])
   ```

4. **Check the response from create_entities**:
   - If your entity appears in the returned list → Entity was created successfully
   - If your entity is missing from the returned list → Entity already existed (use add_observations instead)

5. **Create relationships to connect entities**:
   ```text
   9f1_create_relations(relations: [{
     "from": "AppDataStorage",
     "relationType": "implements",
     "to": "JSON Serialization"
   }])
   ```

## Memory Organization Best Practices

- **Consistent Naming**: Use convention patterns for searchability (`Name`, `Name.Component`)
- **Logical Grouping**: Group entities with common prefixes or entity types
- **Property Ordering**: Maintain order: type, name, entityType, observations
- **Regular Maintenance**: Run the organize_memory.ps1 script weekly
- **Backup Before Changes**: Create backups before bulk modifications
- **Entity Hierarchy**: Use the [Memory Standardization Guidelines](memory-standardization-guidelines.md) relation types
- **Avoid Duplication**: Always search before creating new entities

> **Note**: Tool names may have prefixes (e.g., "9f1_"). Match the available tool names when using them.

---

*Previous: [Main Instructions](main-instructions.md) | Next: [Memory Usage Guide](memory-usage-guide.md)*
