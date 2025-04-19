# Copilot Main Instructions

This guide provides essential information for working efficiently with GitHub Copilot and project memory.

## Core Information Sources

### Knowledge Management

Knowledge management in this workspace is based on Zettelkasten principles. The following resources are essential for understanding and applying these principles:

- [Zettelkasten Methodology](zettelkasten-methodology-technical.md) - Overview of the Zettelkasten system and its principles.
- [Zettelkasten Link Types](link-types-in-zettelkasten-mcp-server.md) - Explanation of the semantic linking system used in the Zettelkasten MCP server.
- [Zettelkasten Protocol](../prompts/system/system-prompt-with-protocol.md) - The protocol for creating and managing notes in the Zettelkasten system.

If you discover new knowledge or insights, please document them in the Zettelkasten system. This includes creating new notes, linking them to existing ones, and updating the knowledge base with relevant information.

If there is no existing content in the Zettelkasten system, try to form a knowledge base with information from `.github/copilot/memory.jsonl`. This file contains a collection of entities, observations, and relationships that can be used to build a foundation for your knowledge management.

### Development Guidelines

| When you need... | Use this document |
|------------------|-------------------|
| Process guidelines | [Workflow Guidelines](workflow-guidelines.md) |
| Coding guidelines | [Coding Guidelines](coding-guidelines.md) |
| Documentation guidelines | [Documentation Guidelines](documentation-guidelines.md) |
| Language-specific guidelines | [Language-Specific Guidelines](language-specific-guidelines.md) |
| Workflow guidelines | [Workflow Guidelines](workflow-guidelines.md) |
| Memory standardization guidelines | [Memory Standardization Guidelines](memory-standardization-guidelines.md) |
| Memory organization guidelines | [Project Memory Organization](project-memory-organization.md) |

## Common Task Patterns

### New Project Exploration

- Examine project structure (`list_dir`)
- Review documentation (`read_file` on README.md, etc.)
- Identify key components, entities and their relationships
- Make detailed notes on findings and create links between them

### Code Modifications

- Search knowledge for context
- Use semantic_search/grep_search to locate relevant code
- Read related files for full understanding
- Use insert_edit_into_file for changes
- Validate with get_errors
- Update knowledge with new observations, entities, and links
- Review and refine knowledge structure

### Knowledge Refinement

- Regularly review knowledge for accuracy and relevance
- Identify and remove outdated or irrelevant information
- Consolidate redundant observations
- Extract core concepts into their own entities
- Create appropriate relation links between entities
