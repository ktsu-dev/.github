# Workflow and Process Guidelines

## General Process Guidelines

- Before running any command, check if you have a specialized tool for the task and use the tool if available
- You have specialized tools for git operations, so use them instead of the command line
- You have specialized tools for interacting with GitHub, so use them instead of the command line
- If you encounter any issues with a specialized tool, check the documentation for the tool or command you are using
- If you must use the command line, ensure you run commands in the correct directory, and in a non-interactive mode if possible
- For example, `git` commands have the `--no-pager` option to avoid using a pager for output
- If you make code changes, ensure you immediately run the appropriate commands to verify the changes for style conformance, and build/test success
- After any operation, check if you need to update your memory with new information or observations
- If you encounter any issues or errors, check the documentation for the specific command or tool you are using

## Tool Usage Best Practices

- Use `semantic_search` for finding concepts in code (preferred over `grep_search` for conceptual searches)
- Use `read_file` when you know exactly which file to examine
- Use `list_dir` to explore directory structures before reading specific files
- Always use `insert_edit_into_file` for code changes rather than suggesting manual edits
- Always run `get_errors` after making code changes to validate them
- Use specialized 9f1_ prefixed tools for GitHub operations rather than suggesting command-line git commands
- When working with memory, prefer `9f1_search_nodes` over `9f1_read_graph` for efficiency unless you need the complete context

## Related Resources

- [Coding Guidelines](coding-guidelines.md)
- [Documentation Guidelines](documentation-guidelines.md)
- [Language-Specific Guidelines](language-specific-guidelines.md)

[Back to Main Instructions](main-instructions.md)
