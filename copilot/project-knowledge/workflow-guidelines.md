# Workflow and Process Guidelines

## Task Execution Framework

1. **Analyze requirements** - Understand what needs to be done
2. **Gather context** - Use tools to collect relevant information
3. **Plan approach** - Break down tasks into logical steps
4. **Execute with validation** - Implement solutions with checks at each step
5. **Document changes** - Update memory and documentation with new information

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
  - For git operations → Use specialized `9f1_` GitHub tools when available
  - For command-line operations → Use `run_in_terminal` with `--no-pager` for git

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
