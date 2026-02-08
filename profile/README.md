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

| Repo | Stable | winget | Activity | Status | README |
|------|--------|--------|----------|--------|--------|
|[BlastMerge](https://github.com/ktsu-dev/BlastMerge)|![GitHub Version](https://img.shields.io/badge/-v1.0.21-181717?logo=github&logoColor=white)|![winget](https://img.shields.io/badge/-v1.0.19-0078D4?logo=windows&logoColor=white)|![Activity](https://img.shields.io/badge/-40-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-failing-d73a4a?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[BuildMonitor](https://github.com/ktsu-dev/BuildMonitor)|![GitHub Version](https://img.shields.io/badge/-v1.2.26-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-100-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[Coder](https://github.com/ktsu-dev/Coder)|![GitHub Version](https://img.shields.io/badge/-v1.0.3-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-33-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-failing-d73a4a?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[CrossRepoActions](https://github.com/ktsu-dev/CrossRepoActions)|![GitHub Version](https://img.shields.io/badge/-v1.2.8-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-100-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[IconHelper](https://github.com/ktsu-dev/IconHelper)|![GitHub Version](https://img.shields.io/badge/-v1.2.6-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-76-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[ProjectDirector](https://github.com/ktsu-dev/ProjectDirector)|![GitHub Version](https://img.shields.io/badge/-v1.0.0-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-78-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-failing-d73a4a?logo=mdbook&logoColor=white)|
|[SvnToGit](https://github.com/ktsu-dev/SvnToGit)|![GitHub Version](https://img.shields.io/badge/-v1.0.2-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-55-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-failing-d73a4a?logo=mdbook&logoColor=white)|
|[SyncFileContents](https://github.com/ktsu-dev/SyncFileContents)|![GitHub Version](https://img.shields.io/badge/-v1.2.10-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-100-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[TUI](https://github.com/ktsu-dev/TUI)|![GitHub Version](https://img.shields.io/badge/-v1.0.4-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-70-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|

### Libraries

| Repo | Stable | Prerelease | Activity | Status | README |
|------|--------|------------|----------|--------|--------|
|[Abstractions](https://github.com/ktsu-dev/Abstractions)|![GitHub Version](https://img.shields.io/badge/-v1.0.13-181717?logo=github&logoColor=white)|![GitHub Prerelease](https://img.shields.io/badge/-v1.0.14--pre.5-181717?logo=github&logoColor=white)|![Activity](https://img.shields.io/badge/-63-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[AppDataStorage](https://github.com/ktsu-dev/AppDataStorage)|![GitHub Version](https://img.shields.io/badge/-v1.15.14-181717?logo=github&logoColor=white)|![GitHub Prerelease](https://img.shields.io/badge/-v1.15.14--pre.11-181717?logo=github&logoColor=white)|![Activity](https://img.shields.io/badge/-100-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[CaseConverter](https://github.com/ktsu-dev/CaseConverter)|![GitHub Version](https://img.shields.io/badge/-v1.3.8-181717?logo=github&logoColor=white)|![GitHub Prerelease](https://img.shields.io/badge/-v1.3.9--pre.7-181717?logo=github&logoColor=white)|![Activity](https://img.shields.io/badge/-69-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[CodeBlocker](https://github.com/ktsu-dev/CodeBlocker)|![GitHub Version](https://img.shields.io/badge/-v1.1.9-181717?logo=github&logoColor=white)|![GitHub Prerelease](https://img.shields.io/badge/-v1.1.10--pre.7-181717?logo=github&logoColor=white)|![Activity](https://img.shields.io/badge/-59-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[Common](https://github.com/ktsu-dev/Common)|![GitHub Version](https://img.shields.io/badge/-v1.0.4-181717?logo=github&logoColor=white)|![GitHub Prerelease](https://img.shields.io/badge/-v1.0.5--pre.7-181717?logo=github&logoColor=white)|![Activity](https://img.shields.io/badge/-61-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[Containers](https://github.com/ktsu-dev/Containers)|![GitHub Version](https://img.shields.io/badge/-v1.0.9-181717?logo=github&logoColor=white)|![GitHub Prerelease](https://img.shields.io/badge/-v1.0.10--pre.7-181717?logo=github&logoColor=white)|![Activity](https://img.shields.io/badge/-53-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[CredentialCache](https://github.com/ktsu-dev/CredentialCache)|![GitHub Version](https://img.shields.io/badge/-v1.2.3-181717?logo=github&logoColor=white)|![GitHub Prerelease](https://img.shields.io/badge/-v1.2.4--pre.16-181717?logo=github&logoColor=white)|![Activity](https://img.shields.io/badge/-31-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-failing-d73a4a?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[DeepClone](https://github.com/ktsu-dev/DeepClone)|![GitHub Version](https://img.shields.io/badge/-v2.0.8-181717?logo=github&logoColor=white)|![GitHub Prerelease](https://img.shields.io/badge/-v2.0.9--pre.5-181717?logo=github&logoColor=white)|![Activity](https://img.shields.io/badge/-61-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[DelegateTransform](https://github.com/ktsu-dev/DelegateTransform)|![GitHub Version](https://img.shields.io/badge/-v1.1.5-181717?logo=github&logoColor=white)|![GitHub Prerelease](https://img.shields.io/badge/-v1.1.6--pre.8-181717?logo=github&logoColor=white)|![Activity](https://img.shields.io/badge/-57-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[Extensions](https://github.com/ktsu-dev/Extensions)|![GitHub Version](https://img.shields.io/badge/-v1.5.11-181717?logo=github&logoColor=white)|![GitHub Prerelease](https://img.shields.io/badge/-v1.5.12--pre.3-181717?logo=github&logoColor=white)|![Activity](https://img.shields.io/badge/-64-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[FileSystemProvider](https://github.com/ktsu-dev/FileSystemProvider)|![GitHub Version](https://img.shields.io/badge/-v1.0.2-181717?logo=github&logoColor=white)|![GitHub Prerelease](https://img.shields.io/badge/-v1.0.3--pre.3-181717?logo=github&logoColor=white)|![Activity](https://img.shields.io/badge/-38-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-failing-d73a4a?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[Frontmatter](https://github.com/ktsu-dev/Frontmatter)|![GitHub Version](https://img.shields.io/badge/-v1.2.2-181717?logo=github&logoColor=white)|![GitHub Prerelease](https://img.shields.io/badge/-v1.2.3--pre.11-181717?logo=github&logoColor=white)|![Activity](https://img.shields.io/badge/-68-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[FuzzySearch](https://github.com/ktsu-dev/FuzzySearch)|![GitHub Version](https://img.shields.io/badge/-v1.2.5-181717?logo=github&logoColor=white)|![GitHub Prerelease](https://img.shields.io/badge/-v1.2.6--pre.8-181717?logo=github&logoColor=white)|![Activity](https://img.shields.io/badge/-57-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[GitIntegration](https://github.com/ktsu-dev/GitIntegration)|![GitHub Version](https://img.shields.io/badge/-v1.1.1-181717?logo=github&logoColor=white)|![GitHub Prerelease](https://img.shields.io/badge/-v1.1.2--pre.18-181717?logo=github&logoColor=white)|![Activity](https://img.shields.io/badge/-31-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-failing-d73a4a?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-failing-d73a4a?logo=mdbook&logoColor=white)|
|[ImGuiApp](https://github.com/ktsu-dev/ImGuiApp)|![GitHub Version](https://img.shields.io/badge/-v2.2.10-181717?logo=github&logoColor=white)|![GitHub Prerelease](https://img.shields.io/badge/-v2.2.11--pre.2-181717?logo=github&logoColor=white)|![Activity](https://img.shields.io/badge/-79-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[ImGuiCredentialPopups](https://github.com/ktsu-dev/ImGuiCredentialPopups)|![GitHub Version](https://img.shields.io/badge/-v1.1.4-181717?logo=github&logoColor=white)|![GitHub Prerelease](https://img.shields.io/badge/-v1.1.5--pre.10-181717?logo=github&logoColor=white)|![Activity](https://img.shields.io/badge/-65-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-failing-d73a4a?logo=mdbook&logoColor=white)|
|[ImGuiProvider](https://github.com/ktsu-dev/ImGuiProvider)|![GitHub Version](https://img.shields.io/badge/-v1.0.0-181717?logo=github&logoColor=white)| |![Activity](https://img.shields.io/badge/-25-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-failing-d73a4a?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-failing-d73a4a?logo=mdbook&logoColor=white)|
|[IntervalAction](https://github.com/ktsu-dev/IntervalAction)|![GitHub Version](https://img.shields.io/badge/-v1.3.7-181717?logo=github&logoColor=white)|![GitHub Prerelease](https://img.shields.io/badge/-v1.3.8--pre.7-181717?logo=github&logoColor=white)|![Activity](https://img.shields.io/badge/-65-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[Invoker](https://github.com/ktsu-dev/Invoker)|![GitHub Version](https://img.shields.io/badge/-v1.1.3-181717?logo=github&logoColor=white)|![GitHub Prerelease](https://img.shields.io/badge/-v1.1.4--pre.7-181717?logo=github&logoColor=white)|![Activity](https://img.shields.io/badge/-58-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[Keybinding](https://github.com/ktsu-dev/Keybinding)|![GitHub Version](https://img.shields.io/badge/-v1.0.6-181717?logo=github&logoColor=white)|![GitHub Prerelease](https://img.shields.io/badge/-v1.0.7--pre.4-181717?logo=github&logoColor=white)|![Activity](https://img.shields.io/badge/-56-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[Navigation](https://github.com/ktsu-dev/Navigation)|![GitHub Version](https://img.shields.io/badge/-v1.0.6-181717?logo=github&logoColor=white)|![GitHub Prerelease](https://img.shields.io/badge/-v1.0.7--pre.3-181717?logo=github&logoColor=white)|![Activity](https://img.shields.io/badge/-51-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[NJsonSchemaJsonConverter](https://github.com/ktsu-dev/NJsonSchemaJsonConverter)|![GitHub Version](https://img.shields.io/badge/-v1.0.1-181717?logo=github&logoColor=white)|![GitHub Prerelease](https://img.shields.io/badge/-v1.0.2--pre.2-181717?logo=github&logoColor=white)|![Activity](https://img.shields.io/badge/-34-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-failing-d73a4a?logo=mdbook&logoColor=white)|
|[PersistenceProvider](https://github.com/ktsu-dev/PersistenceProvider)|![GitHub Version](https://img.shields.io/badge/-v1.0.1-181717?logo=github&logoColor=white)|![GitHub Prerelease](https://img.shields.io/badge/-v1.0.2--pre.4-181717?logo=github&logoColor=white)|![Activity](https://img.shields.io/badge/-35-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-failing-d73a4a?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[PreciseNumber](https://github.com/ktsu-dev/PreciseNumber)|![GitHub Version](https://img.shields.io/badge/-v1.7.5-181717?logo=github&logoColor=white)|![GitHub Prerelease](https://img.shields.io/badge/-v1.7.6--pre.6-181717?logo=github&logoColor=white)|![Activity](https://img.shields.io/badge/-52-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[RoundTripStringJsonConverter](https://github.com/ktsu-dev/RoundTripStringJsonConverter)|![GitHub Version](https://img.shields.io/badge/-v1.0.7-181717?logo=github&logoColor=white)|![GitHub Prerelease](https://img.shields.io/badge/-v1.0.8--pre.3-181717?logo=github&logoColor=white)|![Activity](https://img.shields.io/badge/-60-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[RunCommand](https://github.com/ktsu-dev/RunCommand)|![GitHub Version](https://img.shields.io/badge/-v1.3.5-181717?logo=github&logoColor=white)|![GitHub Prerelease](https://img.shields.io/badge/-v1.3.6--pre.5-181717?logo=github&logoColor=white)|![Activity](https://img.shields.io/badge/-59-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[Schema](https://github.com/ktsu-dev/Schema)|![GitHub Version](https://img.shields.io/badge/-v1.3.4-181717?logo=github&logoColor=white)|![GitHub Prerelease](https://img.shields.io/badge/-v1.3.4--pre.7-181717?logo=github&logoColor=white)|![Activity](https://img.shields.io/badge/-56-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-failing-d73a4a?logo=mdbook&logoColor=white)|
|[ScopedAction](https://github.com/ktsu-dev/ScopedAction)|![GitHub Version](https://img.shields.io/badge/-v1.1.7-181717?logo=github&logoColor=white)|![GitHub Prerelease](https://img.shields.io/badge/-v1.1.8--pre.8-181717?logo=github&logoColor=white)|![Activity](https://img.shields.io/badge/-60-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[Semantics](https://github.com/ktsu-dev/Semantics)|![GitHub Version](https://img.shields.io/badge/-v1.0.29-181717?logo=github&logoColor=white)|![GitHub Prerelease](https://img.shields.io/badge/-v1.0.30--pre.10-181717?logo=github&logoColor=white)|![Activity](https://img.shields.io/badge/-100-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[SerializationProvider](https://github.com/ktsu-dev/SerializationProvider)|![GitHub Version](https://img.shields.io/badge/-v1.0.5-181717?logo=github&logoColor=white)|![GitHub Prerelease](https://img.shields.io/badge/-v1.0.6--pre.1-181717?logo=github&logoColor=white)|![Activity](https://img.shields.io/badge/-30-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[SignificantNumber](https://github.com/ktsu-dev/SignificantNumber)|![GitHub Version](https://img.shields.io/badge/-v1.4.5-181717?logo=github&logoColor=white)|![GitHub Prerelease](https://img.shields.io/badge/-v1.4.6--pre.8-181717?logo=github&logoColor=white)|![Activity](https://img.shields.io/badge/-56-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[SingleAppInstance](https://github.com/ktsu-dev/SingleAppInstance)|![GitHub Version](https://img.shields.io/badge/-v1.2.11-181717?logo=github&logoColor=white)|![GitHub Prerelease](https://img.shields.io/badge/-v1.2.12--pre.12-181717?logo=github&logoColor=white)|![Activity](https://img.shields.io/badge/-96-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[Sorting](https://github.com/ktsu-dev/Sorting)|![GitHub Version](https://img.shields.io/badge/-v1.0.4-181717?logo=github&logoColor=white)|![GitHub Prerelease](https://img.shields.io/badge/-v1.0.5--pre.8-181717?logo=github&logoColor=white)|![Activity](https://img.shields.io/badge/-58-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[TextFilter](https://github.com/ktsu-dev/TextFilter)|![GitHub Version](https://img.shields.io/badge/-v1.5.6-181717?logo=github&logoColor=white)|![GitHub Prerelease](https://img.shields.io/badge/-v1.5.7--pre.7-181717?logo=github&logoColor=white)|![Activity](https://img.shields.io/badge/-55-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[ThemeProvider](https://github.com/ktsu-dev/ThemeProvider)|![GitHub Version](https://img.shields.io/badge/-v1.0.13-181717?logo=github&logoColor=white)|![GitHub Prerelease](https://img.shields.io/badge/-v1.0.14--pre.7-181717?logo=github&logoColor=white)|![Activity](https://img.shields.io/badge/-61-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[UndoRedo](https://github.com/ktsu-dev/UndoRedo)|![GitHub Version](https://img.shields.io/badge/-v1.0.6-181717?logo=github&logoColor=white)|![GitHub Prerelease](https://img.shields.io/badge/-v1.0.7--pre.5-181717?logo=github&logoColor=white)|![Activity](https://img.shields.io/badge/-66-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[UniversalSerializer](https://github.com/ktsu-dev/UniversalSerializer)|![GitHub Version](https://img.shields.io/badge/-v1.0.6-181717?logo=github&logoColor=white)|![GitHub Prerelease](https://img.shields.io/badge/-v1.0.7--pre.1-181717?logo=github&logoColor=white)|![Activity](https://img.shields.io/badge/-46-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|

