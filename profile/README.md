# ktsu.dev

**.NET libraries and tools that use strong typing and focused APIs to catch errors at compile time instead of at runtime.**

ktsu.dev is a collection of open source .NET libraries built and maintained by [Matt Edmondson](https://github.com/matt-edmondson). It started in May 2023 and now spans more than 60 public repositories, published to NuGet under the `ktsu.*` namespace. Each library solves one specific problem with a small, clear API, reflecting lessons learned from years of building production systems in games and live services.

## Design Principles

**Strong Typing and Semantic Clarity.** Replace primitive types with domain-specific types, because a bug caught at compile time is cheaper than the same bug found in production. Types carry intent, so code reads as what it means.

**Focused APIs.** Each library does one job with a small surface area. Boilerplate and ceremony are kept out of the caller's code.

**Composable Infrastructure.** Provider-pattern libraries put an interface between application code and infrastructure, so backends can be swapped and tested without rewriting the code that uses them.

**Modern .NET with Broad Reach.** Libraries use current platform features (generic math, nullable reference types, the latest language versions) while multi-targeting from netstandard2.1 through the newest .NET, so older codebases can still consume them.

## Key Libraries

### Type Safety and Semantics

- **[Semantics](https://github.com/ktsu-dev/Semantics)**: semantic strings with validation, strongly typed file paths, and over 80 physical quantities with compile-time dimensional analysis
- **[PreciseNumber](https://github.com/ktsu-dev/PreciseNumber)**: arbitrary precision arithmetic built on .NET generic math
- **[SignificantNumber](https://github.com/ktsu-dev/SignificantNumber)**: arithmetic that preserves numerical precision through significant figures

### Providers

- **[PersistenceProvider](https://github.com/ktsu-dev/PersistenceProvider)**: unified persistence with swappable storage backends (Memory, FileSystem, AppData, Temporary)
- **[SerializationProvider](https://github.com/ktsu-dev/SerializationProvider)**: serialization behind a common interface so formats can change without touching call sites
- **[FileSystemProvider](https://github.com/ktsu-dev/FileSystemProvider)**: file system access as an injectable, testable dependency
- **[ThemeProvider](https://github.com/ktsu-dev/ThemeProvider)**: theme management and styling using color science and semantic remapping
- **[ImGuiProvider](https://github.com/ktsu-dev/ImGuiProvider)**: ImGui abstraction layer for backend-independent UI code

### UI and Tools

- **[ImGuiApp](https://github.com/ktsu-dev/ImGuiApp)**: Dear ImGui application scaffolding, widgets, modal dialogs, and styling
- **[BlastMerge](https://github.com/ktsu-dev/BlastMerge)**: cross-repository file synchronization through iterative merging with interactive conflict resolution

### Utilities

- **[UniversalSerializer](https://github.com/ktsu-dev/UniversalSerializer)**: one serialization API across JSON, XML, YAML, TOML, and MessagePack
- **[IntervalAction](https://github.com/ktsu-dev/IntervalAction)**: recurring actions without manual timer management
- **[Invoker](https://github.com/ktsu-dev/Invoker)**: thread-safe delegate execution for UI applications
- **[ScopedAction](https://github.com/ktsu-dev/ScopedAction)**: RAII-style setup and teardown patterns
- **[CaseConverter](https://github.com/ktsu-dev/CaseConverter)**: string case conversion
- **[FuzzySearch](https://github.com/ktsu-dev/FuzzySearch)**: approximate string matching
- **[SingleAppInstance](https://github.com/ktsu-dev/SingleAppInstance)**: prevent multiple application instances

## Getting Started

All libraries ship as NuGet packages:

```bash
dotnet add package ktsu.Semantics.Strings
dotnet add package ktsu.PersistenceProvider
dotnet add package ktsu.ImGui.App
```

## ktsu.Sdk

**[ktsu.Sdk](https://github.com/ktsu-dev/Sdk)** is the MSBuild SDK that every ktsu.dev library builds on. Centralizing the build configuration means a fix or a standards change lands in one place and every repository picks it up.

The SDK provides:

- **Build Configuration**: shared compiler settings, warnings, and code analysis rules across all projects
- **Code Quality Enforcement**: integrated analyzers and style rules, with warnings treated as errors
- **Automated Packaging**: NuGet package generation with versioning and metadata
- **Development Tools**: common build targets and utilities for library development

### Usage

Reference the SDK in the project file alongside the standard .NET SDK:

```xml
<Project>
  <Sdk Name="Microsoft.NET.Sdk" />
  <Sdk Name="ktsu.Sdk" />

  <!-- Your project configuration -->
</Project>
```

Pin SDK versions in `global.json` so every project in a solution builds with the same toolchain and updates happen in one place:

```json
{
  "sdk": {
    "version": "9.0.301",
    "rollForward": "latestFeature"
  },
  "msbuild-sdks": {
    "MSTest.Sdk": "4.0.2",
    "ktsu.Sdk": "1.75.0",
    "ktsu.Sdk.ConsoleApp": "1.75.0",
    "ktsu.Sdk.App": "1.75.0"
  }
}
```

## Project Status

### Applications

| Repo | Stable | winget | Activity | Status | README |
|------|--------|--------|----------|--------|--------|
|[BlastMerge](https://github.com/ktsu-dev/BlastMerge)|![GitHub Version](https://img.shields.io/badge/-v1.1.4-181717?logo=github&logoColor=white)|![winget](https://img.shields.io/badge/-v1.0.21-0078D4?logo=windows&logoColor=white)|![Activity](https://img.shields.io/badge/-35-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[BuildMonitor](https://github.com/ktsu-dev/BuildMonitor)|![GitHub Version](https://img.shields.io/badge/-v1.4.17-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-90-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[Coder](https://github.com/ktsu-dev/Coder)|![GitHub Version](https://img.shields.io/badge/-v1.0.9-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-33-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[FileDeduplicator](https://github.com/ktsu-dev/FileDeduplicator)|![GitHub Version](https://img.shields.io/badge/-v1.0.41-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-78-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[IconHelper](https://github.com/ktsu-dev/IconHelper)|![GitHub Version](https://img.shields.io/badge/-v1.4.11-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-81-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[ImageDescriber](https://github.com/ktsu-dev/ImageDescriber)|![GitHub Version](https://img.shields.io/badge/-v1.1.79-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-93-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[KtsuTools](https://github.com/ktsu-dev/KtsuTools)|![GitHub Version](https://img.shields.io/badge/-v1.0.2-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-59-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-failing-d73a4a?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[ProjectDirector](https://github.com/ktsu-dev/ProjectDirector)|![GitHub Version](https://img.shields.io/badge/-v1.1.1-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-87-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[SvnToGit](https://github.com/ktsu-dev/SvnToGit)|![GitHub Version](https://img.shields.io/badge/-v1.0.22-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-64-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[TUI](https://github.com/ktsu-dev/TUI)|![GitHub Version](https://img.shields.io/badge/-v1.0.48-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-59-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-failing-d73a4a?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|

### Libraries

| Repo | Stable | Prerelease | Activity | Status | README |
|------|--------|------------|----------|--------|--------|
|[AppDataStorage](https://github.com/ktsu-dev/AppDataStorage)|![GitHub Version](https://img.shields.io/badge/-v1.16.42-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-89-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[CaseConverter](https://github.com/ktsu-dev/CaseConverter)|![GitHub Version](https://img.shields.io/badge/-v1.3.33-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-64-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[CodeBlocker](https://github.com/ktsu-dev/CodeBlocker)|![GitHub Version](https://img.shields.io/badge/-v1.2.13-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-68-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[Containers](https://github.com/ktsu-dev/Containers)|![GitHub Version](https://img.shields.io/badge/-v1.1.14-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-64-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-cancelled-6e7681?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[CredentialCache](https://github.com/ktsu-dev/CredentialCache)|![GitHub Version](https://img.shields.io/badge/-v1.3.27-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-87-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[DeepClone](https://github.com/ktsu-dev/DeepClone)|![GitHub Version](https://img.shields.io/badge/-v2.0.28-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-62-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[DelegateTransform](https://github.com/ktsu-dev/DelegateTransform)|![GitHub Version](https://img.shields.io/badge/-v1.1.23-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-65-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[Essentials](https://github.com/ktsu-dev/Essentials)|![GitHub Version](https://img.shields.io/badge/-v2.2.1-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-62-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-unknown-dbab09?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[Extensions](https://github.com/ktsu-dev/Extensions)|![GitHub Version](https://img.shields.io/badge/-v1.6.6-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-65-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[Frontmatter](https://github.com/ktsu-dev/Frontmatter)|![GitHub Version](https://img.shields.io/badge/-v1.2.20-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-71-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[FuzzySearch](https://github.com/ktsu-dev/FuzzySearch)|![GitHub Version](https://img.shields.io/badge/-v1.2.37-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-61-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[GitBranchStateCache](https://github.com/ktsu-dev/GitBranchStateCache)|![GitHub Version](https://img.shields.io/badge/-v1.0.3-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-17-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[GitIntegration](https://github.com/ktsu-dev/GitIntegration)|![GitHub Version](https://img.shields.io/badge/-v2.4.0-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-100-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[GitLfsCache](https://github.com/ktsu-dev/GitLfsCache)|![GitHub Version](https://img.shields.io/badge/-v1.8.4-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-66-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[ImGuiApp](https://github.com/ktsu-dev/ImGuiApp)|![GitHub Version](https://img.shields.io/badge/-v3.10.0-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-100-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-unknown-dbab09?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[ImGuiCredentialPopups](https://github.com/ktsu-dev/ImGuiCredentialPopups)|![GitHub Version](https://img.shields.io/badge/-v1.1.49-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-100-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[ImGuiProvider](https://github.com/ktsu-dev/ImGuiProvider)|![GitHub Version](https://img.shields.io/badge/-v1.1.21-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-63-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[IntervalAction](https://github.com/ktsu-dev/IntervalAction)|![GitHub Version](https://img.shields.io/badge/-v1.3.38-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-65-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[Invoker](https://github.com/ktsu-dev/Invoker)|![GitHub Version](https://img.shields.io/badge/-v1.2.24-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-65-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[JsonRequiredConditionally](https://github.com/ktsu-dev/JsonRequiredConditionally)|![GitHub Version](https://img.shields.io/badge/-v1.1.9-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-86-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[Keybinding](https://github.com/ktsu-dev/Keybinding)|![GitHub Version](https://img.shields.io/badge/-v1.0.32-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-86-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[KtsuBuild](https://github.com/ktsu-dev/KtsuBuild)|![GitHub Version](https://img.shields.io/badge/-v2.3.0-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-97-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[Navigation](https://github.com/ktsu-dev/Navigation)|![GitHub Version](https://img.shields.io/badge/-v1.0.23-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-58-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[NJsonSchemaJsonConverter](https://github.com/ktsu-dev/NJsonSchemaJsonConverter)|![GitHub Version](https://img.shields.io/badge/-v1.0.38-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-56-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[PreciseNumber](https://github.com/ktsu-dev/PreciseNumber)|![GitHub Version](https://img.shields.io/badge/-v1.7.33-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-63-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[RoundTripStringJsonConverter](https://github.com/ktsu-dev/RoundTripStringJsonConverter)|![GitHub Version](https://img.shields.io/badge/-v1.0.44-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-85-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[RunCommand](https://github.com/ktsu-dev/RunCommand)|![GitHub Version](https://img.shields.io/badge/-v1.5.3-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-73-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[Schema](https://github.com/ktsu-dev/Schema)|![GitHub Version](https://img.shields.io/badge/-v1.7.7-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-81-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[ScopedAction](https://github.com/ktsu-dev/ScopedAction)|![GitHub Version](https://img.shields.io/badge/-v1.1.33-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-64-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[Semantics](https://github.com/ktsu-dev/Semantics)|![GitHub Version](https://img.shields.io/badge/-v3.1.2-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-100-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[SignificantNumber](https://github.com/ktsu-dev/SignificantNumber)|![GitHub Version](https://img.shields.io/badge/-v1.4.33-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-70-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[SingleAppInstance](https://github.com/ktsu-dev/SingleAppInstance)|![GitHub Version](https://img.shields.io/badge/-v1.3.48-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-84-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[Sorting](https://github.com/ktsu-dev/Sorting)|![GitHub Version](https://img.shields.io/badge/-v1.0.30-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-65-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[TextFilter](https://github.com/ktsu-dev/TextFilter)|![GitHub Version](https://img.shields.io/badge/-v1.5.38-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-66-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[ThemeProvider](https://github.com/ktsu-dev/ThemeProvider)|![GitHub Version](https://img.shields.io/badge/-v3.0.7-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-99-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[UndoRedo](https://github.com/ktsu-dev/UndoRedo)|![GitHub Version](https://img.shields.io/badge/-v1.0.17-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-61-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|

