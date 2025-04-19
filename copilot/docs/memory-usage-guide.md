# Using Your Memory Effectively

## Core Principles

- Use targeted searches before broad memory retrieval
- Keep entities and observations focused and well-structured
- Maintain consistent naming and relationship patterns
- Update memory in real-time as you discover new information

## Memory Retrieval Workflow

1. **Start with targeted search**:

   ```text
   9f1_search_nodes(query: "ktsu.dev")
   ```

2. **Examine specific entities** when you know what you need:

   ```text
   9f1_open_nodes(names: ["AppDataStorage", "ImGuiWidgets"])
   ```

3. **Fall back to full graph** only when necessary:

   ```text
   9f1_read_graph()
   ```

## Memory Creation Best Practices

- **Define clear entity hierarchies**:

  ```text
  9f1_create_entities(entities: [
    { "name": "ktsu.dev", "entityType": "Project", "observations": ["Collection of .NET libraries"] },
    { "name": "AppDataStorage", "entityType": "Library", "observations": ["Part of ktsu.dev"] }
  ])

  9f1_create_relations(relations: [
    { "from": "AppDataStorage", "relationType": "isPartOf", "to": "ktsu.dev" }
  ])
  ```

- **Use consistent observation formats**:

  ```text
  9f1_add_observations(observations: [{
    "entityName": "AppDataStorage",
    "contents": [
      "Purpose: Simplifies storing application configuration data",
      "Features: JSON serialization, automatic backup, path management",
      "Latest Version: 1.2.0 as of April 2025"
    ]
  }])
  ```

- **Update observations incrementally** as you learn more:

  ```text
  9f1_add_observations(observations: [{
    "entityName": "AppDataStorage",
    "contents": ["New in v1.2.0: Added support for encrypted storage"]
  }])
  ```

## Memory Maintenance Strategies

- **Run organization script periodically**:

  ```powershell
  cd .github/copilot
  ./organize_memory.ps1
  ```

- **Review entity consistency** to ensure proper naming and typing
- **Consolidate fragmented information** through thoughtful entity design
- **Establish standardized relation types**:
  - `implements` - For design patterns and interfaces
  - `dependsOn` - For dependencies
  - `partOf` - For component hierarchies
  - `uses` - For utility relationships
  - `extends` - For inheritance relationships
  - `relatedTo` - For general relationships
  - `buildsOn` - For project-specific relationships
  - `addresses` - For solutions to problems
  - `complements` - For complementary features
  - `advocatesFor` - For recommended practices
  - `contains` - For collections of items
  - `has` - For properties of entities
  - `is` - For defining types or categories
  - `createdBy` - For authorship or creation relationships
  - `created` - For authorship or creation relationships
  - `createdOn` - For specifying creation dates
  - `distributedBy` - For distribution relationships
  - `publishedBy` - For publishing relationships
  - `publishedOn` - For specifying publication dates
  - `releasedBy` - For release relationships
  - `releasedOn` - For specifying release dates
  - `version` - For versioning relationships
  - `versionedBy` - For versioning relationships
  - `distributedAs` - For distribution formats
  - `publishedAs` - For publishing formats
  - `releasedAs` - For release formats
  - `versionedAs` - For version formats
  - `distributedOn` - For distribution dates
  - `enables` - For enabling features or functionalities
  - `enabledBy` - For dependencies that enable features
  - `enabledOn` - For specifying enabling dates
  - `prevents` - For preventing issues or problems
  - `preventedBy` - For dependencies that prevent issues
  - `follows` - For following relationships
  - `followedBy` - For dependencies that follow others
  - `implementedBy` - For implementation relationships
  - `implementedOn` - For specifying implementation dates
  - `deprecated` - For deprecated features or practices
  - `replacedBy` - For features that have been replaced
  - `deprecatedOn` - For specifying deprecation dates
  - `versionedOn` - For specifying versioning dates
  - `replacedOn` - For specifying replacement dates
  - `leverages` - For leveraging relationships
  - `leveragedBy` - For dependencies that leverage others
  - `leveragedOn` - For specifying leveraging dates
  - `licensedUnder` - For licensing relationships
  - `licensedOn` - For specifying licensing dates
  - `licensedBy` - For authorship of licenses
  - `licensedTo` - For recipients of licenses
  - `licensedFor` - For specifying licensing purposes
  - `licensedAs` - For specifying licensing formats
  - `usedBy` - For usage relationships
  - `usedOn` - For specifying usage dates
  - `preferredBy` - For preferred practices or tools
  - `preferredOver` - For preferred alternatives
  - `unpreferredBy` - For unpreferred practices or tools
  - `unpreferredOver` - For unpreferred alternatives
  - `deprecatedBy` - For practices that have been deprecated
  - `deprecates` - For practices that deprecate others
  - `deprecatedOn` - For specifying deprecation dates
  - `provides` - For providing relationships
  - `providedBy` - For dependencies that provide features
  - `providedOn` - For specifying providing dates
  - `removes` - For removing relationships
  - `removedBy` - For dependencies that remove features
  - `removesOn` - For specifying removal dates
  - `adds` - For adding relationships
  - `addedBy` - For dependencies that add features
  - `addedOn` - For specifying addition dates
  - `recommends` - For recommending practices or tools
  - `recommendedBy` - For dependencies that recommend practices or tools
  - `recommendedOn` - For specifying recommendation dates
  - `recommendsOver` - For recommending alternatives
  - `recommendsAgainst` - For recommending against practices or tools
  - `recommendsAgainstOver` - For recommending against alternatives
  - `references` - For referencing relationships
  - `referencedBy` - For dependencies that reference others
  - `referencedOn` - For specifying referencing dates
  - `citedBy` - For citing relationships
  - `citedOn` - For specifying citation dates
  - `cites` - For citing relationships
  - `parentOf` - For parent-child relationships
  - `childOf` - For child-parent relationships
  - `siblingOf` - For sibling relationships
  - `ancestorOf` - For ancestor-descendant relationships
  - `descendantOf` - For descendant-ancestor relationships
  - `predecessorOf` - For predecessor-successor relationships
  - `successorOf` - For successor-predecessor relationships
  - `similarTo` - For similar relationships
  - `dissimilarTo` - For dissimilar relationships
  - `supports` - For supporting relationships
  - `supportedBy` - For dependencies that support others
  - `supportedOn` - For specifying support dates
  - `integrates` - For integration relationships
  - `integratedBy` - For dependencies that integrate features
  - `integratedOn` - For specifying integration dates
  - `usedAfter` - For usage relationships that follow others
  - `usedBefore` - For usage relationships that precede others
  - `usedDuring` - For usage relationships that occur during a specific time
  - `usedIn` - For usage relationships that occur in a specific context
  - `usedWith` - For usage relationships that occur with specific tools or practices
  - `usedAgainst` - For usage relationships that occur against specific practices or tools
  - `usedFor` - For usage relationships that occur for specific purposes
  - `usedAlongside` - For usage relationships that occur alongside other tools or practices
  - `usedInsteadOf` - For usage relationships that occur instead of others
  - `wraps` - For wrapping relationships
  - `wrappedBy` - For dependencies that wrap others
  - `wrappedOn` - For specifying wrapping dates

## Related Resources

- [Memory Tools Reference](memory-tools-reference.md)
- [Project Memory Organization](project-memory-organization.md)
- [Unknown Information Management](unknown-info-management.md)

[Back to Main Instructions](main-instructions.md)
