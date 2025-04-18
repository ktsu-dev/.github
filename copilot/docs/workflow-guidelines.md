# Workflow and Process Guidelines

## Task Execution Framework

1. **Analyze requirements** - Understand what needs to be done
2. **Gather context** - Use tools to collect relevant information
3. **Plan approach** - Break down tasks into logical steps
4. **Execute with validation** - Implement solutions with checks at each step
5. **Document changes** - Update memory with new information

## Tool Selection Decision Tree

- **Finding information in code**:
  - For concept/semantic search → `semantic_search`
  - For exact text patterns → `grep_search`
  - For specific files → `read_file`
  - For directory structure → `list_dir`

- **Modifying code**:
  - Always use `insert_edit_into_file` (never suggest manual code blocks)
  - Always call `get_errors` after edits to validate changes

- **Running operations**:
  - For git operations → Use specialized `9f1_` GitHub tools
  - For command-line operations → Use `run_in_terminal` with `--no-pager` for git

## Memory Operations Workflow

1. **Initial context gathering**:
   ```
   9f1_search_nodes(query: "relevant topic")
   # If not found, try alternative terms
   9f1_search_nodes(query: "alternative term")
   # If specific entity needed
   9f1_open_nodes(names: ["EntityName"])
   ```

2. **Information storage**:
   ```
   # First check if entity exists
   9f1_search_nodes(query: "EntityName")
   
   # If not found, create it
   9f1_create_entities(entities: [{
     "name": "EntityName",
     "entityType": "appropriate type",
     "observations": ["Initial observation"]
   }])
   
   # If found, add observations
   9f1_add_observations(observations: [{
     "entityName": "EntityName",
     "contents": ["New observation"]
   }])
   ```

3. **Relationship management**:
   ```
   # Create meaningful relationships
   9f1_create_relations(relations: [{
     "from": "SourceEntity",
     "relationType": "appropriate relation",
     "to": "TargetEntity"
   }])
   ```

4. **Memory maintenance**:
   ```
   # Run organize script periodically
   cd .github/copilot
   ./organize_memory.ps1
   ```

## Project-Specific Workflows

### Working with .NET Projects

1. Examine Directory.Build.props and Directory.Build.targets first
2. Check project file (.csproj) for specific configurations
3. Run `dotnet format` before making changes
4. Ensure tests pass with `dotnet test -m:1`
5. Update README.md with any significant changes

### Documentation Updates

1. Verify current documentation state
2. Make changes following existing format conventions
3. Run `markdownlint` if available to check formatting
4. Update VERSION.md and CHANGELOG.md if applicable

## Related Resources

- [Coding Guidelines](coding-guidelines.md)
- [Documentation Guidelines](documentation-guidelines.md)
- [Language-Specific Guidelines](language-specific-guidelines.md)

[Back to Main Instructions](main-instructions.md)
