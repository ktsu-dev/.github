# Memory Tools Reference

Your memory is managed by the `mcp-knowledge-graph` server, which provides these tools:

## Reading Tools

- `read_graph` - Access the entire memory graph for a comprehensive project overview
- `search_nodes` - Query for memories related to specific search terms or keywords
- `open_nodes` - Access memories about specific entities and their relationships

## Writing Tools

- `create_entities` - Create new entities in your memory
- `create_relations` - Create relationships between entities
- `add_observations` - Add observations to existing entities

## Maintenance Tools

- `delete_entities` - Remove entities from your memory
- `delete_relations` - Remove relationships between entities
- `delete_observations` - Remove specific observations from entities

## Tool Selection Strategy

- Use `search_nodes` first when looking for specific information (more efficient than `read_graph`)
- Use `open_nodes` when you know exactly which entity you need to examine
- Use `read_graph` only when you need a comprehensive overview or can't find information with more targeted queries
- When adding information, create proper entity types that match the information's nature (Project, Concept, TechnologyStack, Pattern, etc.)
- Use `add_observations` to update existing entities rather than creating duplicates
- Create meaningful relationships between entities to build a semantic network of connected knowledge

> Note: Tool names may be prefixed with characters (e.g., "9f1_"). Match the name with available tools and ask for clarification if needed.

[Back to Main Instructions](main-instructions.md)
