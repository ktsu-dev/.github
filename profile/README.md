# ktsu.dev

**Modern .NET libraries that eliminate boilerplate, catch errors early, and make code self-documenting.**

ktsu.dev is a collection of focused .NET libraries designed to reduce cognitive load and minimize runtime errors through strong typing and semantic clarity. Each library solves a specific problem with clean APIs that integrate seamlessly with modern .NET practices.

## Core Philosophy

**Strong Typing & Semantic Clarity** – Replace primitive types with domain-specific types that catch errors at compile time and make code intent clear.

**Simplified APIs** – Eliminate boilerplate and abstract complex operations behind intuitive interfaces.

**Maintainable Design** – Single-responsibility libraries with comprehensive testing and consistent patterns.

**Modern .NET** – Leverage latest language features, generic math, and .NET 8+ capabilities.

## Key Libraries

### Type Safety & Semantics

- **[Semantics](https://github.com/ktsu-dev/Semantics)** – Comprehensive semantic types including strings, paths, and 80+ physics quantities
- **[PreciseNumber](https://github.com/ktsu-dev/PreciseNumber)** – Arbitrary precision arithmetic with .NET 7+ generic math
- **[SignificantNumber](https://github.com/ktsu-dev/SignificantNumber)** – Preserve numerical precision with significant figures

### Simplified APIs

- **[PersistenceProvider](https://github.com/ktsu-dev/PersistenceProvider)** – Unified persistence with multiple storage backends (Memory, FileSystem, AppData, Temporary)
- **[UniversalSerializer](https://github.com/ktsu-dev/UniversalSerializer)** – Unified serialization supporting JSON, XML, YAML, TOML, MessagePack
- **[IntervalAction](https://github.com/ktsu-dev/IntervalAction)** – Easy recurring actions without timer management
- **[Invoker](https://github.com/ktsu-dev/Invoker)** – Thread-safe delegate execution for UI apps
- **[ScopedAction](https://github.com/ktsu-dev/ScopedAction)** – RAII-style setup/teardown patterns

### UI & Tools

- **[ImGuiApp](https://github.com/ktsu-dev/ImGuiApp)** – Dear ImGui application scaffolding, widgets, modal dialogs, and styling
- **[ImGuiProvider](https://github.com/ktsu-dev/ImGuiProvider)** – ImGui provider abstraction layer
- **[ThemeProvider](https://github.com/ktsu-dev/ThemeProvider)** – Theme management and styling using color science and semantic remapping

### Utilities

- **[CaseConverter](https://github.com/ktsu-dev/CaseConverter)** – String case conversion
- **[FuzzySearch](https://github.com/ktsu-dev/FuzzySearch)** – Approximate string matching
- **[SingleAppInstance](https://github.com/ktsu-dev/SingleAppInstance)** – Prevent multiple app instances

## Getting Started

All libraries are available as NuGet packages:

```bash
dotnet add package ktsu.Semantics.Strings
dotnet add package ktsu.PersistenceProvider
dotnet add package ktsu.ImGui.App
```

## ktsu.Sdk

**[ktsu.Sdk](https://github.com/ktsu-dev/Sdk)** is the foundational build SDK that powers all ktsu.dev libraries.

This MSBuild SDK provides:
- **Consistent Build Configuration** – Shared compiler settings, warnings, and code analysis rules across all projects
- **Code Quality Enforcement** – Integrated analyzers and style rules that maintain code standards
- **Automated Packaging** – NuGet package generation with proper versioning and metadata
- **Development Tools** – Common build targets and utilities for library development

All ktsu.dev projects reference this SDK to ensure consistency, maintainability, and adherence to best practices. It's the backbone that enables the entire ecosystem to maintain high quality standards.

### Usage

Reference the SDK in your project file alongside the standard .NET SDK:

```xml
<Project>
  <Sdk Name="Microsoft.NET.Sdk" />
  <Sdk Name="ktsu.Sdk" />

  <!-- Your project configuration -->
</Project>
```

For version management of the sdks, use `global.json`:

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

This approach ensures consistent SDK versions across all projects in your solution and makes updates centralized and straightforward.

## Project Status

### Applications

| Repo | Stable | winget | choco | brew | scoop | apt | aur | yum | Downloads | Activity | Status | README |
|------|--------|--------|-------|------|-------|-----|-----|-----|-----------|----------|--------|--------|
|[BlastMerge](https://github.com/ktsu-dev/BlastMerge)|![NuGet Version](https://img.shields.io/badge/-v1-004880?logo=nuget&logoColor=white)| | | | |⚠| |⚠|![Downloads](https://img.shields.io/badge/-1K-004880?logo=nuget&logoColor=white)|![Activity](https://img.shields.io/badge/-1-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[BuildMonitor](https://github.com/ktsu-dev/BuildMonitor)|![GitHub Version](https://img.shields.io/badge/-v1.2.5-181717?logo=github&logoColor=white)| | | | |⚠| |⚠| |![Activity](https://img.shields.io/badge/-24-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-failing-d73a4a?logo=github&logoColor=white)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[Coder](https://github.com/ktsu-dev/Coder)|![GitHub Version](https://img.shields.io/badge/-v1.0.3-181717?logo=github&logoColor=white)| | | | | | |⚠| |![Activity](https://img.shields.io/badge/-1-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-failing-d73a4a?logo=github&logoColor=white)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[CrossRepoActions](https://github.com/ktsu-dev/CrossRepoActions)|![GitHub Version](https://img.shields.io/badge/-v1.2.2-181717?logo=github&logoColor=white)| | | | |⚠| |⚠| |![Activity](https://img.shields.io/badge/-4-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-failing-d73a4a?logo=github&logoColor=white)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[IconHelper](https://github.com/ktsu-dev/IconHelper)|![GitHub Version](https://img.shields.io/badge/-v1.2.5-181717?logo=github&logoColor=white)| | | | |⚠| |⚠| |![Activity](https://img.shields.io/badge/-9-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-failing-d73a4a?logo=github&logoColor=white)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[SyncFileContents](https://github.com/ktsu-dev/SyncFileContents)|![GitHub Version](https://img.shields.io/badge/-v1.2.4-181717?logo=github&logoColor=white)| | | | |⚠| |⚠| |![Activity](https://img.shields.io/badge/-7-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|

### Libraries

| Repo | Stable | Prerelease | Downloads | Activity | Status | README |
|------|--------|------------|-----------|----------|--------|--------|
|[Abstractions](https://github.com/ktsu-dev/Abstractions)|![NuGet Version](https://img.shields.io/badge/-v1.0.10-004880?logo=nuget&logoColor=white)|![NuGet Prerelease](https://img.shields.io/badge/-v1.0.11-pre.3-004880?logo=nuget&logoColor=white)|![Downloads](https://img.shields.io/badge/-4.2K-004880?logo=nuget&logoColor=white)|![Activity](https://img.shields.io/badge/-1-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[AppDataStorage](https://github.com/ktsu-dev/AppDataStorage)|![NuGet Version](https://img.shields.io/badge/-v1.15.11-004880?logo=nuget&logoColor=white)|![NuGet Prerelease](https://img.shields.io/badge/-v1.15.12-pre.1-004880?logo=nuget&logoColor=white)|![Downloads](https://img.shields.io/badge/-51.5K-004880?logo=nuget&logoColor=white)|![Activity](https://img.shields.io/badge/-41-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-failing-d73a4a?logo=github&logoColor=white)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[CaseConverter](https://github.com/ktsu-dev/CaseConverter)|![NuGet Version](https://img.shields.io/badge/-v1.3.4-004880?logo=nuget&logoColor=white)|![NuGet Prerelease](https://img.shields.io/badge/-v1.3.5-pre.3-004880?logo=nuget&logoColor=white)|![Downloads](https://img.shields.io/badge/-35K-004880?logo=nuget&logoColor=white)|![Activity](https://img.shields.io/badge/-1-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[CodeBlocker](https://github.com/ktsu-dev/CodeBlocker)|![NuGet Version](https://img.shields.io/badge/-v1.1.7-004880?logo=nuget&logoColor=white)|![NuGet Prerelease](https://img.shields.io/badge/-v1.1.8-pre.3-004880?logo=nuget&logoColor=white)|![Downloads](https://img.shields.io/badge/-14K-004880?logo=nuget&logoColor=white)|![Activity](https://img.shields.io/badge/-1-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[Common](https://github.com/ktsu-dev/Common)|![GitHub Version](https://img.shields.io/badge/-v1.0.2-181717?logo=github&logoColor=white)|![GitHub Prerelease](https://img.shields.io/badge/-v1.0.3-pre.3-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-1-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[Containers](https://github.com/ktsu-dev/Containers)|![NuGet Version](https://img.shields.io/badge/-v1.0.7-004880?logo=nuget&logoColor=white)|![NuGet Prerelease](https://img.shields.io/badge/-v1.0.8-pre.3-004880?logo=nuget&logoColor=white)|![Downloads](https://img.shields.io/badge/-2.8K-004880?logo=nuget&logoColor=white)|![Activity](https://img.shields.io/badge/-1-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[CredentialCache](https://github.com/ktsu-dev/CredentialCache)|![NuGet Version](https://img.shields.io/badge/-v1.2.3-004880?logo=nuget&logoColor=white)|![NuGet Prerelease](https://img.shields.io/badge/-v1.2.4-pre.16-004880?logo=nuget&logoColor=white)|![Downloads](https://img.shields.io/badge/-14.2K-004880?logo=nuget&logoColor=white)|![Activity](https://img.shields.io/badge/-1-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-failing-d73a4a?logo=github&logoColor=white)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[DeepClone](https://github.com/ktsu-dev/DeepClone)|![NuGet Version](https://img.shields.io/badge/-v2.0.5-004880?logo=nuget&logoColor=white)|![NuGet Prerelease](https://img.shields.io/badge/-v2.0.6-pre.3-004880?logo=nuget&logoColor=white)|![Downloads](https://img.shields.io/badge/-43.1K-004880?logo=nuget&logoColor=white)|![Activity](https://img.shields.io/badge/-1-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[DelegateTransform](https://github.com/ktsu-dev/DelegateTransform)|![NuGet Version](https://img.shields.io/badge/-v1.1.3-004880?logo=nuget&logoColor=white)|![NuGet Prerelease](https://img.shields.io/badge/-v1.1.3-pre.17-004880?logo=nuget&logoColor=white)|![Downloads](https://img.shields.io/badge/-6.3K-004880?logo=nuget&logoColor=white)|![Activity](https://img.shields.io/badge/-1-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-failing-d73a4a?logo=github&logoColor=white)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[Extensions](https://github.com/ktsu-dev/Extensions)|![NuGet Version](https://img.shields.io/badge/-v1.5.8-004880?logo=nuget&logoColor=white)|![NuGet Prerelease](https://img.shields.io/badge/-v1.5.9-pre.3-004880?logo=nuget&logoColor=white)|![Downloads](https://img.shields.io/badge/-59.7K-004880?logo=nuget&logoColor=white)|![Activity](https://img.shields.io/badge/-1-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[FileSystemProvider](https://github.com/ktsu-dev/FileSystemProvider)|![NuGet Version](https://img.shields.io/badge/-v1.0.2-004880?logo=nuget&logoColor=white)|![NuGet Prerelease](https://img.shields.io/badge/-v1.0.3-pre.3-004880?logo=nuget&logoColor=white)|![Downloads](https://img.shields.io/badge/-1.8K-004880?logo=nuget&logoColor=white)|![Activity](https://img.shields.io/badge/-1-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[Frontmatter](https://github.com/ktsu-dev/Frontmatter)|![NuGet Version](https://img.shields.io/badge/-v1.2.0-004880?logo=nuget&logoColor=white)| |![Downloads](https://img.shields.io/badge/-546-004880?logo=nuget&logoColor=white)|![Activity](https://img.shields.io/badge/-1-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-failing-d73a4a?logo=github&logoColor=white)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[FuzzySearch](https://github.com/ktsu-dev/FuzzySearch)|![NuGet Version](https://img.shields.io/badge/-v1.2.3-004880?logo=nuget&logoColor=white)|![NuGet Prerelease](https://img.shields.io/badge/-v1.2.4-pre.3-004880?logo=nuget&logoColor=white)|![Downloads](https://img.shields.io/badge/-20.8K-004880?logo=nuget&logoColor=white)|![Activity](https://img.shields.io/badge/-1-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[GitIntegration](https://github.com/ktsu-dev/GitIntegration)|![NuGet Version](https://img.shields.io/badge/-v1.1.1-004880?logo=nuget&logoColor=white)|![NuGet Prerelease](https://img.shields.io/badge/-v1.1.2-pre.18-004880?logo=nuget&logoColor=white)|![Downloads](https://img.shields.io/badge/-5.3K-004880?logo=nuget&logoColor=white)|![Activity](https://img.shields.io/badge/-1-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-failing-d73a4a?logo=github&logoColor=white)|![README](https://img.shields.io/badge/failing-red?label=&logo=mdbook)|
|[ImGuiApp](https://github.com/ktsu-dev/ImGuiApp)|![NuGet Version](https://img.shields.io/badge/-v2.1.7-004880?logo=nuget&logoColor=white)|![NuGet Prerelease](https://img.shields.io/badge/-v2.0.7-pre.1-004880?logo=nuget&logoColor=white)|![Downloads](https://img.shields.io/badge/-27.1K-004880?logo=nuget&logoColor=white)|![Activity](https://img.shields.io/badge/-5-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[ImGuiCredentialPopups](https://github.com/ktsu-dev/ImGuiCredentialPopups)|![NuGet Version](https://img.shields.io/badge/-v1.1.3-004880?logo=nuget&logoColor=white)|![NuGet Prerelease](https://img.shields.io/badge/-v1.1.4-pre.8-004880?logo=nuget&logoColor=white)|![Downloads](https://img.shields.io/badge/-13.3K-004880?logo=nuget&logoColor=white)|![Activity](https://img.shields.io/badge/-1-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-failing-d73a4a?logo=github&logoColor=white)|![README](https://img.shields.io/badge/failing-red?label=&logo=mdbook)|
|[ImGuiProvider](https://github.com/ktsu-dev/ImGuiProvider)|![GitHub Version](https://img.shields.io/badge/-v1.0.0-181717?logo=github&logoColor=white)| | | |![Status](https://img.shields.io/badge/-failing-d73a4a?logo=github&logoColor=white)|![README](https://img.shields.io/badge/failing-red?label=&logo=mdbook)|
|[IntervalAction](https://github.com/ktsu-dev/IntervalAction)|![NuGet Version](https://img.shields.io/badge/-v1.3.4-004880?logo=nuget&logoColor=white)|![NuGet Prerelease](https://img.shields.io/badge/-v1.3.4-pre.4-004880?logo=nuget&logoColor=white)|![Downloads](https://img.shields.io/badge/-6.3K-004880?logo=nuget&logoColor=white)|![Activity](https://img.shields.io/badge/-6-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[Invoker](https://github.com/ktsu-dev/Invoker)|![NuGet Version](https://img.shields.io/badge/-v1.1.1-004880?logo=nuget&logoColor=white)|![NuGet Prerelease](https://img.shields.io/badge/-v1.1.2-pre.4-004880?logo=nuget&logoColor=white)|![Downloads](https://img.shields.io/badge/-5.5K-004880?logo=nuget&logoColor=white)|![Activity](https://img.shields.io/badge/-1-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[Keybinding](https://github.com/ktsu-dev/Keybinding)|![GitHub Version](https://img.shields.io/badge/-v1.0.3-181717?logo=github&logoColor=white)| | |![Activity](https://img.shields.io/badge/-3-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-failing-d73a4a?logo=github&logoColor=white)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[Navigation](https://github.com/ktsu-dev/Navigation)|![GitHub Version](https://img.shields.io/badge/-v1.0.5-181717?logo=github&logoColor=white)|![GitHub Prerelease](https://img.shields.io/badge/-v1.0.6-pre.4-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-1-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-failing-d73a4a?logo=github&logoColor=white)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[NJsonSchemaJsonConverter](https://github.com/ktsu-dev/NJsonSchemaJsonConverter)|![NuGet Version](https://img.shields.io/badge/-v0-004880?logo=nuget&logoColor=white)|![NuGet Prerelease](https://img.shields.io/badge/-v1.0.1-pre.18-004880?logo=nuget&logoColor=white)|![Downloads](https://img.shields.io/badge/-4.7K-004880?logo=nuget&logoColor=white)|![Activity](https://img.shields.io/badge/-1-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-failing-d73a4a?logo=github&logoColor=white)|![README](https://img.shields.io/badge/failing-red?label=&logo=mdbook)|
|[PersistenceProvider](https://github.com/ktsu-dev/PersistenceProvider)|![NuGet Version](https://img.shields.io/badge/-v1-004880?logo=nuget&logoColor=white)|![NuGet Prerelease](https://img.shields.io/badge/-v1.0.2-pre.4-004880?logo=nuget&logoColor=white)|![Downloads](https://img.shields.io/badge/-791-004880?logo=nuget&logoColor=white)|![Activity](https://img.shields.io/badge/-1-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[PreciseNumber](https://github.com/ktsu-dev/PreciseNumber)|![NuGet Version](https://img.shields.io/badge/-v1.7.2-004880?logo=nuget&logoColor=white)|![NuGet Prerelease](https://img.shields.io/badge/-v1.7.3-pre.4-004880?logo=nuget&logoColor=white)|![Downloads](https://img.shields.io/badge/-5.7K-004880?logo=nuget&logoColor=white)|![Activity](https://img.shields.io/badge/-1-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[RoundTripStringJsonConverter](https://github.com/ktsu-dev/RoundTripStringJsonConverter)|![NuGet Version](https://img.shields.io/badge/-v1.0.4-004880?logo=nuget&logoColor=white)|![NuGet Prerelease](https://img.shields.io/badge/-v1.0.5-pre.4-004880?logo=nuget&logoColor=white)|![Downloads](https://img.shields.io/badge/-3.8K-004880?logo=nuget&logoColor=white)|![Activity](https://img.shields.io/badge/-1-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[RunCommand](https://github.com/ktsu-dev/RunCommand)|![NuGet Version](https://img.shields.io/badge/-v1.3.2-004880?logo=nuget&logoColor=white)|![NuGet Prerelease](https://img.shields.io/badge/-v1.3.3-pre.4-004880?logo=nuget&logoColor=white)|![Downloads](https://img.shields.io/badge/-2.3K-004880?logo=nuget&logoColor=white)|![Activity](https://img.shields.io/badge/-1-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[Schema](https://github.com/ktsu-dev/Schema)|![NuGet Version](https://img.shields.io/badge/-v1.3.1-004880?logo=nuget&logoColor=white)|![NuGet Prerelease](https://img.shields.io/badge/-v1.3.2-pre.2-004880?logo=nuget&logoColor=white)|![Downloads](https://img.shields.io/badge/-3.7K-004880?logo=nuget&logoColor=white)|![Activity](https://img.shields.io/badge/-1-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-failing-d73a4a?logo=github&logoColor=white)|![README](https://img.shields.io/badge/failing-red?label=&logo=mdbook)|
|[ScopedAction](https://github.com/ktsu-dev/ScopedAction)|![NuGet Version](https://img.shields.io/badge/-v1.1.5-004880?logo=nuget&logoColor=white)|![NuGet Prerelease](https://img.shields.io/badge/-v1.1.6-pre.4-004880?logo=nuget&logoColor=white)|![Downloads](https://img.shields.io/badge/-30.6K-004880?logo=nuget&logoColor=white)|![Activity](https://img.shields.io/badge/-1-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[Semantics](https://github.com/ktsu-dev/Semantics)|![NuGet Version](https://img.shields.io/badge/-v1.0.20-004880?logo=nuget&logoColor=white)|![NuGet Prerelease](https://img.shields.io/badge/-v1.0.20-pre.1-004880?logo=nuget&logoColor=white)|![Downloads](https://img.shields.io/badge/-7K-004880?logo=nuget&logoColor=white)|![Activity](https://img.shields.io/badge/-25-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-failing-d73a4a?logo=github&logoColor=white)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[SignificantNumber](https://github.com/ktsu-dev/SignificantNumber)|![NuGet Version](https://img.shields.io/badge/-v1.4.3-004880?logo=nuget&logoColor=white)|![NuGet Prerelease](https://img.shields.io/badge/-v1.4.4-pre.4-004880?logo=nuget&logoColor=white)|![Downloads](https://img.shields.io/badge/-8.9K-004880?logo=nuget&logoColor=white)|![Activity](https://img.shields.io/badge/-1-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[SingleAppInstance](https://github.com/ktsu-dev/SingleAppInstance)|![NuGet Version](https://img.shields.io/badge/-v1.2.9-004880?logo=nuget&logoColor=white)|![NuGet Prerelease](https://img.shields.io/badge/-v1.2.8-pre.1-004880?logo=nuget&logoColor=white)|![Downloads](https://img.shields.io/badge/-8.5K-004880?logo=nuget&logoColor=white)|![Activity](https://img.shields.io/badge/-39-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-failing-d73a4a?logo=github&logoColor=white)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[Sorting](https://github.com/ktsu-dev/Sorting)|![NuGet Version](https://img.shields.io/badge/-v1.0.2-004880?logo=nuget&logoColor=white)|![NuGet Prerelease](https://img.shields.io/badge/-v1.0.3-pre.4-004880?logo=nuget&logoColor=white)|![Downloads](https://img.shields.io/badge/-2.2K-004880?logo=nuget&logoColor=white)|![Activity](https://img.shields.io/badge/-1-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[TextFilter](https://github.com/ktsu-dev/TextFilter)|![NuGet Version](https://img.shields.io/badge/-v1.5.4-004880?logo=nuget&logoColor=white)|![NuGet Prerelease](https://img.shields.io/badge/-v1.5.5-pre.4-004880?logo=nuget&logoColor=white)|![Downloads](https://img.shields.io/badge/-17.9K-004880?logo=nuget&logoColor=white)|![Activity](https://img.shields.io/badge/-1-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[ThemeProvider](https://github.com/ktsu-dev/ThemeProvider)|![NuGet Version](https://img.shields.io/badge/-v1.0.10-004880?logo=nuget&logoColor=white)|![NuGet Prerelease](https://img.shields.io/badge/-v1.0.11-pre.3-004880?logo=nuget&logoColor=white)|![Downloads](https://img.shields.io/badge/-6.4K-004880?logo=nuget&logoColor=white)|![Activity](https://img.shields.io/badge/-1-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[TUI](https://github.com/ktsu-dev/TUI)|![GitHub Version](https://img.shields.io/badge/-v1.0.1-181717?logo=github&logoColor=white)|![GitHub Prerelease](https://img.shields.io/badge/-v1.0.2-pre.3-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-3-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-failing-d73a4a?logo=github&logoColor=white)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[UndoRedo](https://github.com/ktsu-dev/UndoRedo)|![GitHub Version](https://img.shields.io/badge/-v1.0.2-181717?logo=github&logoColor=white)|![GitHub Prerelease](https://img.shields.io/badge/-v1.0.3-pre.1-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-10-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-failing-d73a4a?logo=github&logoColor=white)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[UniversalSerializer](https://github.com/ktsu-dev/UniversalSerializer)|![NuGet Version](https://img.shields.io/badge/-v1.0.4-004880?logo=nuget&logoColor=white)|![NuGet Prerelease](https://img.shields.io/badge/-v1.0.5-pre.4-004880?logo=nuget&logoColor=white)|![Downloads](https://img.shields.io/badge/-2.4K-004880?logo=nuget&logoColor=white)|![Activity](https://img.shields.io/badge/-1-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-failing-d73a4a?logo=github&logoColor=white)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|

