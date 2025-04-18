# Copilot Instructions

This document serves as the main entry point for GitHub Copilot instructions. Each section links to a more detailed document.

## Table of Contents

- [Memory Tools Reference](memory-tools-reference.md) - Available tools for managing your memory
- [Memory Usage Guide](memory-usage-guide.md) - How to use your memory effectively
- [Project Memory Organization](project-memory-organization.md) - How to organize project memory
- [Unknown Information Management](unknown-info-management.md) - How to handle missing information
- [Project Knowledge Management](project-knowledge-management.md) - Managing project knowledge
- [Workflow Guidelines](workflow-guidelines.md) - Process guidelines for development
- [Coding Guidelines](coding-guidelines.md) - General coding guidelines and style
- [Documentation Guidelines](documentation-guidelines.md) - Guidelines for documentation
- [Language-Specific Guidelines](language-specific-guidelines.md) - .NET/C# and Markdown guidelines

## Getting Started

> Note: Tool names may be prefixed with characters (e.g., "9f1_"). Match the name with available tools and ask for clarification if needed.

Always begin new tasks by recalling project information using the `search_nodes` and `open_nodes` tools.

If you're unsure what information you need, start with the `read_graph` tool to retrieve all of the stored information about the project. Only use this as a fallback if you can't find the information you need using the other tools first.

## Quick Reference

### Memory Management Tools

- `read_graph` - Get all stored information (use sparingly due to token usage)
- `search_nodes` - Search for specific topics or keywords (preferred first approach)
- `open_nodes` - Access specific entities by exact name
- `create_entities` - Add new concepts, components or information
- `create_relations` - Connect existing entities with meaningful relationships
- `add_observations` - Append new information to existing entities

### Memory Maintenance

The `.github/copilot/organize_memory.ps1` script helps maintain memory organization by:
- Creating timestamped backups before changes
- Sorting entities by logical type groups
- Arranging properties in consistent order
- Organizing relations after entities

Run this script periodically to keep memory files well-structured.

### Workflow Efficiency Tips

- Use context-focused memory searches rather than retrieving all information
- Organize task approaches with step-by-step plans before execution
- Document memory changes including what was added and why
- Always validate code changes with appropriate testing tools
- Create memory entities for common procedures and patterns
- Update memory with discovered project information in real-time

Refer to the individual documents linked above for detailed instructions on each topic.
