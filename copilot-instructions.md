# Copilot Instructions

## Quick Reference

Use these core memory tools to effectively manage project knowledge:

```text
9f1_search_nodes(query: "keyword")         # Search for information (use first)
9f1_open_nodes(names: ["EntityName"])      # Access specific entities
9f1_read_graph()                           # Access all memory (use sparingly)
9f1_add_observations(observations: [{...}]) # Update existing entities (use before create_entities)
9f1_create_entities(entities: [{...}])     # Add new entities (use after add_observations)
9f1_create_relations(relations: [{...}])   # Link related entities
```

## Communication Style

Prefer terse, concise language. Focus on clarity and directness over politeness.

## Documentation Structure

All detailed instructions are in the `.github/copilot/docs/` directory:

- [Main Instructions](copilot/docs/main-instructions.md) - Start here for guidance

### Key Topics

1. **Memory Management**
   - [Memory Tools Reference](copilot/docs/memory-tools-reference.md) - Tool usage with examples
   - [Memory Usage Guide](copilot/docs/memory-usage-guide.md) - Best practices
   - [Project Memory Organization](copilot/docs/project-memory-organization.md) - Entity structure

2. **Knowledge Management**
   - [Unknown Information Management](copilot/docs/unknown-info-management.md) - Discovery process
   - [Project Knowledge Management](copilot/docs/project-knowledge-management.md) - Knowledge tracking

3. **Development Guidelines**
   - [Workflow Guidelines](copilot/docs/workflow-guidelines.md) - Process and tools
   - [Coding Guidelines](copilot/docs/coding-guidelines.md) - Code standards
   - [Documentation Guidelines](copilot/docs/documentation-guidelines.md) - Doc standards
   - [Language-Specific Guidelines](copilot/docs/language-specific-guidelines.md) - Language guides

## Memory Maintenance

Always run the memory organization script periodically:

```powershell
cd .github/copilot
./organize_memory.ps1
```

This script:

- Creates timestamped backups
- Sorts entities by type and name
- Standardizes property ordering (type, name, entityType, observations)
- Places relations after entities
