# Managing Unknown Information

## Systematic Discovery Process

When encountering a new project or missing information:

1. **Investigate project structure**

   ```text
   list_dir(path: "/path/to/project")
   ```

2. **Examine key documentation files**

   ```text
   read_file(filePath: "/path/to/project/README.md", startLineNumberBaseZero: 0, endLineNumberBaseZero: 50)
   ```

3. **Search for conceptual information**

   ```text
   semantic_search(query: "project purpose and features")
   ```

4. **Review configuration files**

   ```text
   file_search(query: "**/*.csproj")
   file_search(query: "**/Directory.Build.*")
   ```

## Information Capture Framework

For each discovered component:

1. **Create base entities with key metadata**

   ```text
   9f1_create_entities(entities: [{
     "name": "ComponentName",
     "entityType": "Library",
     "observations": ["Initial discovery on DATE", "Basic purpose: DESCRIPTION"]
   }])
   ```

2. **Document relationships**

   ```text
   9f1_create_relations(relations: [{
     "from": "ComponentName",
     "relationType": "dependsOn",
     "to": "DependencyName"
   }])
   ```

3. **Enrich with detailed observations**

   ```text
   9f1_add_observations(observations: [{
     "entityName": "ComponentName",
     "contents": [
       "Architecture: PATTERN_USED",
       "Key Features: FEATURE_LIST",
       "Found in: FILE_PATH"
     ]
   }])
   ```

## Priority Information Categories

Focus discovery efforts on:

1. **Project Identity**
   - Name, purpose, vision, goals
   - Target audience and use cases
   - Project status and maturity

2. **Technical Foundation**
   - Language and framework versions
   - Architecture and design patterns
   - Dependencies and third-party libraries

3. **Development Practices**
   - Coding standards and conventions
   - Testing approach and coverage
   - Documentation practices
   - Release and versioning strategy

4. **Domain Knowledge**
   - Core concepts and terminology
   - Business rules and constraints
   - Data models and relationships

## Information Reliability Tracking

Include confidence indicators in observations:

```text
9f1_add_observations(observations: [{
  "entityName": "ComponentName",
  "contents": [
    "Confirmed: Component implements pattern X",
    "Likely: Feature Y is supported based on references in tests",
    "Uncertain: May depend on external service Z"
  ]
}])
```

## Related Resources

- [Memory Usage Guide](memory-usage-guide.md)
- [Project Memory Organization](project-memory-organization.md)

[Back to Main Instructions](main-instructions.md)
