# Copilot Instructions

This guide provides essential information for working efficiently with GitHub Copilot and project memory.

## Quick Start

1. **Find information**: Start with targeted memory searches

   ```text
   9f1_search_nodes(query: "relevant keywords")
   ```

2. **Access known entities**: Look up specific entities by name

   ```text
   9f1_open_nodes(names: ["EntityName"])
   ```

3. **Update memory**: Store new discoveries immediately

   ```text
   9f1_add_observations(observations: [{
     "entityName": "EntityName",
     "contents": ["New observation"]
   }])
   ```

4. **Modify code**: Always use insert_edit_into_file tool followed by get_errors

   ```text
   insert_edit_into_file(filePath, explanation, code)
   get_errors(filePaths: [filePath])
   ```

## Core Information Sources

| When you need... | Use this document |
|------------------|-------------------|
| Tool reference & examples | [Memory Tools Reference](memory-tools-reference.md) |
| Memory creation patterns | [Memory Usage Guide](memory-usage-guide.md) |
| Memory standardization | [Memory Standardization Guidelines](memory-standardization-guidelines.md) |
| Entity structure guidance | [Project Memory Organization](project-memory-organization.md) |
| Discovery process | [Unknown Information Management](unknown-info-management.md) |
| Knowledge tracking | [Project Knowledge Management](project-knowledge-management.md) |
| Process guidelines | [Workflow Guidelines](workflow-guidelines.md) |
| Coding standards | [Coding Guidelines](coding-guidelines.md) |
| Documentation standards | [Documentation Guidelines](documentation-guidelines.md) |
| Language-specific guides | [Language-Specific Guidelines](language-specific-guidelines.md) |

## Key Best Practices

- **Search before retrieve**: Use targeted searches instead of reading the full graph
- **Memory first**: Check memory before exploring code to avoid redundant work
- **Progressive enhancement**: Start with core information and add details incrementally
- **Consistent structure**: Follow entity type conventions and standard relation patterns
- **Validate changes**: Always confirm code modifications with appropriate validation tools
- **Maintain organization**: Run the organize_memory.ps1 script periodically

## Memory Maintenance

The `.github/copilot/organize_memory.ps1` script helps maintain memory organization:

```powershell
cd .github/copilot
./organize_memory.ps1
```

This script:

- Creates timestamped backups
- Sorts entities by logical groups
- Standardizes property ordering
- Places relations after entities

## Common Task Patterns

### New Project Exploration

1. Examine project structure (`list_dir`)
2. Review documentation (`read_file` on README.md, etc.)
3. Create base project entities in memory
4. Document component relationships
5. Add detailed observations as discovered

### Code Modifications

1. Search memory for context
2. Use semantic_search/grep_search to locate relevant code
3. Read related files for full understanding
4. Use insert_edit_into_file for changes
5. Validate with get_errors
6. Update memory with new observations
