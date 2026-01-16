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

### Libraries

| Repo | Stable | Prerelease | Downloads | Activity | Status | README |
|------|--------|------------|-----------|----------|--------|--------|
|[Abstractions](https://github.com/ktsu-dev/Abstractions)|![NuGet Version](https://img.shields.io/nuget/v/ktsu.Abstractions?label=&logo=nuget)| |![NuGet Downloads](https://img.shields.io/nuget/dt/ktsu.Abstractions?label=&logo=nuget)|![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/Abstractions?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/Abstractions/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[AppDataStorage](https://github.com/ktsu-dev/AppDataStorage)|![NuGet Version](https://img.shields.io/nuget/v/ktsu.AppDataStorage?label=&logo=nuget)| |![NuGet Downloads](https://img.shields.io/nuget/dt/ktsu.AppDataStorage?label=&logo=nuget)|![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/AppDataStorage?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/AppDataStorage/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[CaseConverter](https://github.com/ktsu-dev/CaseConverter)|![NuGet Version](https://img.shields.io/nuget/v/ktsu.CaseConverter?label=&logo=nuget)| |![NuGet Downloads](https://img.shields.io/nuget/dt/ktsu.CaseConverter?label=&logo=nuget)|![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/CaseConverter?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/CaseConverter/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[CodeBlocker](https://github.com/ktsu-dev/CodeBlocker)|![NuGet Version](https://img.shields.io/nuget/v/ktsu.CodeBlocker?label=&logo=nuget)| |![NuGet Downloads](https://img.shields.io/nuget/dt/ktsu.CodeBlocker?label=&logo=nuget)|![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/CodeBlocker?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/CodeBlocker/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[Common](https://github.com/ktsu-dev/Common)|![GitHub Version](https://img.shields.io/github/v/release/ktsu-dev/Common?label=&logo=github)| | |![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/Common?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/Common/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[Containers](https://github.com/ktsu-dev/Containers)|![NuGet Version](https://img.shields.io/nuget/v/ktsu.Containers?label=&logo=nuget)| |![NuGet Downloads](https://img.shields.io/nuget/dt/ktsu.Containers?label=&logo=nuget)|![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/Containers?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/Containers/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[CredentialCache](https://github.com/ktsu-dev/CredentialCache)|![NuGet Version](https://img.shields.io/nuget/v/ktsu.CredentialCache?label=&logo=nuget)| |![NuGet Downloads](https://img.shields.io/nuget/dt/ktsu.CredentialCache?label=&logo=nuget)|![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/CredentialCache?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/CredentialCache/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[DeepClone](https://github.com/ktsu-dev/DeepClone)|![NuGet Version](https://img.shields.io/nuget/v/ktsu.DeepClone?label=&logo=nuget)| |![NuGet Downloads](https://img.shields.io/nuget/dt/ktsu.DeepClone?label=&logo=nuget)|![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/DeepClone?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/DeepClone/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[DelegateTransform](https://github.com/ktsu-dev/DelegateTransform)|![NuGet Version](https://img.shields.io/nuget/v/ktsu.DelegateTransform?label=&logo=nuget)| |![NuGet Downloads](https://img.shields.io/nuget/dt/ktsu.DelegateTransform?label=&logo=nuget)|![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/DelegateTransform?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/DelegateTransform/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[Extensions](https://github.com/ktsu-dev/Extensions)|![NuGet Version](https://img.shields.io/nuget/v/ktsu.Extensions?label=&logo=nuget)| |![NuGet Downloads](https://img.shields.io/nuget/dt/ktsu.Extensions?label=&logo=nuget)|![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/Extensions?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/Extensions/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[FileSystemProvider](https://github.com/ktsu-dev/FileSystemProvider)|![NuGet Version](https://img.shields.io/nuget/v/ktsu.FileSystemProvider?label=&logo=nuget)| |![NuGet Downloads](https://img.shields.io/nuget/dt/ktsu.FileSystemProvider?label=&logo=nuget)|![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/FileSystemProvider?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/FileSystemProvider/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[Frontmatter](https://github.com/ktsu-dev/Frontmatter)|![NuGet Version](https://img.shields.io/nuget/v/ktsu.Frontmatter?label=&logo=nuget)| |![NuGet Downloads](https://img.shields.io/nuget/dt/ktsu.Frontmatter?label=&logo=nuget)|![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/Frontmatter?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/Frontmatter/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[FuzzySearch](https://github.com/ktsu-dev/FuzzySearch)|![NuGet Version](https://img.shields.io/nuget/v/ktsu.FuzzySearch?label=&logo=nuget)| |![NuGet Downloads](https://img.shields.io/nuget/dt/ktsu.FuzzySearch?label=&logo=nuget)|![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/FuzzySearch?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/FuzzySearch/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[GitIntegration](https://github.com/ktsu-dev/GitIntegration)|![NuGet Version](https://img.shields.io/nuget/v/ktsu.GitIntegration?label=&logo=nuget)| |![NuGet Downloads](https://img.shields.io/nuget/dt/ktsu.GitIntegration?label=&logo=nuget)|![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/GitIntegration?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/GitIntegration/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/failing-red?label=&logo=mdbook)|
|[ImGuiApp](https://github.com/ktsu-dev/ImGuiApp)|![NuGet Version](https://img.shields.io/nuget/v/ktsu.ImGuiApp?label=&logo=nuget)| |![NuGet Downloads](https://img.shields.io/nuget/dt/ktsu.ImGuiApp?label=&logo=nuget)|![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/ImGuiApp?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/ImGuiApp/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[ImGuiCredentialPopups](https://github.com/ktsu-dev/ImGuiCredentialPopups)|![NuGet Version](https://img.shields.io/nuget/v/ktsu.ImGuiCredentialPopups?label=&logo=nuget)| |![NuGet Downloads](https://img.shields.io/nuget/dt/ktsu.ImGuiCredentialPopups?label=&logo=nuget)|![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/ImGuiCredentialPopups?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/ImGuiCredentialPopups/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/failing-red?label=&logo=mdbook)|
|[ImGuiProvider](https://github.com/ktsu-dev/ImGuiProvider)|![GitHub Version](https://img.shields.io/github/v/release/ktsu-dev/ImGuiProvider?label=&logo=github)| | |![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/ImGuiProvider?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/ImGuiProvider/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/failing-red?label=&logo=mdbook)|
|[IntervalAction](https://github.com/ktsu-dev/IntervalAction)|![NuGet Version](https://img.shields.io/nuget/v/ktsu.IntervalAction?label=&logo=nuget)| |![NuGet Downloads](https://img.shields.io/nuget/dt/ktsu.IntervalAction?label=&logo=nuget)|![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/IntervalAction?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/IntervalAction/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[Invoker](https://github.com/ktsu-dev/Invoker)|![NuGet Version](https://img.shields.io/nuget/v/ktsu.Invoker?label=&logo=nuget)| |![NuGet Downloads](https://img.shields.io/nuget/dt/ktsu.Invoker?label=&logo=nuget)|![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/Invoker?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/Invoker/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[Keybinding](https://github.com/ktsu-dev/Keybinding)|![GitHub Version](https://img.shields.io/github/v/release/ktsu-dev/Keybinding?label=&logo=github)| | |![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/Keybinding?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/Keybinding/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[Navigation](https://github.com/ktsu-dev/Navigation)|![GitHub Version](https://img.shields.io/github/v/release/ktsu-dev/Navigation?label=&logo=github)| | |![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/Navigation?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/Navigation/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[NJsonSchemaJsonConverter](https://github.com/ktsu-dev/NJsonSchemaJsonConverter)|![NuGet Version](https://img.shields.io/nuget/v/ktsu.NJsonSchemaJsonConverter?label=&logo=nuget)| |![NuGet Downloads](https://img.shields.io/nuget/dt/ktsu.NJsonSchemaJsonConverter?label=&logo=nuget)|![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/NJsonSchemaJsonConverter?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/NJsonSchemaJsonConverter/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/failing-red?label=&logo=mdbook)|
|[PersistenceProvider](https://github.com/ktsu-dev/PersistenceProvider)|![NuGet Version](https://img.shields.io/nuget/v/ktsu.PersistenceProvider?label=&logo=nuget)| |![NuGet Downloads](https://img.shields.io/nuget/dt/ktsu.PersistenceProvider?label=&logo=nuget)|![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/PersistenceProvider?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/PersistenceProvider/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[PreciseNumber](https://github.com/ktsu-dev/PreciseNumber)|![NuGet Version](https://img.shields.io/nuget/v/ktsu.PreciseNumber?label=&logo=nuget)| |![NuGet Downloads](https://img.shields.io/nuget/dt/ktsu.PreciseNumber?label=&logo=nuget)|![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/PreciseNumber?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/PreciseNumber/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[RoundTripStringJsonConverter](https://github.com/ktsu-dev/RoundTripStringJsonConverter)|![NuGet Version](https://img.shields.io/nuget/v/ktsu.RoundTripStringJsonConverter?label=&logo=nuget)| |![NuGet Downloads](https://img.shields.io/nuget/dt/ktsu.RoundTripStringJsonConverter?label=&logo=nuget)|![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/RoundTripStringJsonConverter?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/RoundTripStringJsonConverter/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[RunCommand](https://github.com/ktsu-dev/RunCommand)|![NuGet Version](https://img.shields.io/nuget/v/ktsu.RunCommand?label=&logo=nuget)| |![NuGet Downloads](https://img.shields.io/nuget/dt/ktsu.RunCommand?label=&logo=nuget)|![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/RunCommand?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/RunCommand/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[Schema](https://github.com/ktsu-dev/Schema)|![NuGet Version](https://img.shields.io/nuget/v/ktsu.Schema?label=&logo=nuget)| |![NuGet Downloads](https://img.shields.io/nuget/dt/ktsu.Schema?label=&logo=nuget)|![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/Schema?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/Schema/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/failing-red?label=&logo=mdbook)|
|[ScopedAction](https://github.com/ktsu-dev/ScopedAction)|![NuGet Version](https://img.shields.io/nuget/v/ktsu.ScopedAction?label=&logo=nuget)| |![NuGet Downloads](https://img.shields.io/nuget/dt/ktsu.ScopedAction?label=&logo=nuget)|![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/ScopedAction?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/ScopedAction/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[Semantics](https://github.com/ktsu-dev/Semantics)|![NuGet Version](https://img.shields.io/nuget/v/ktsu.Semantics?label=&logo=nuget)| |![NuGet Downloads](https://img.shields.io/nuget/dt/ktsu.Semantics?label=&logo=nuget)|![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/Semantics?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/Semantics/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[SignificantNumber](https://github.com/ktsu-dev/SignificantNumber)|![NuGet Version](https://img.shields.io/nuget/v/ktsu.SignificantNumber?label=&logo=nuget)| |![NuGet Downloads](https://img.shields.io/nuget/dt/ktsu.SignificantNumber?label=&logo=nuget)|![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/SignificantNumber?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/SignificantNumber/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[SingleAppInstance](https://github.com/ktsu-dev/SingleAppInstance)|![NuGet Version](https://img.shields.io/nuget/v/ktsu.SingleAppInstance?label=&logo=nuget)| |![NuGet Downloads](https://img.shields.io/nuget/dt/ktsu.SingleAppInstance?label=&logo=nuget)|![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/SingleAppInstance?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/SingleAppInstance/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[Sorting](https://github.com/ktsu-dev/Sorting)|![NuGet Version](https://img.shields.io/nuget/v/ktsu.Sorting?label=&logo=nuget)| |![NuGet Downloads](https://img.shields.io/nuget/dt/ktsu.Sorting?label=&logo=nuget)|![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/Sorting?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/Sorting/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[TextFilter](https://github.com/ktsu-dev/TextFilter)|![NuGet Version](https://img.shields.io/nuget/v/ktsu.TextFilter?label=&logo=nuget)| |![NuGet Downloads](https://img.shields.io/nuget/dt/ktsu.TextFilter?label=&logo=nuget)|![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/TextFilter?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/TextFilter/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[ThemeProvider](https://github.com/ktsu-dev/ThemeProvider)|![NuGet Version](https://img.shields.io/nuget/v/ktsu.ThemeProvider?label=&logo=nuget)| |![NuGet Downloads](https://img.shields.io/nuget/dt/ktsu.ThemeProvider?label=&logo=nuget)|![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/ThemeProvider?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/ThemeProvider/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[TUI](https://github.com/ktsu-dev/TUI)|![GitHub Version](https://img.shields.io/github/v/release/ktsu-dev/TUI?label=&logo=github)| | |![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/TUI?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/TUI/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[UndoRedo](https://github.com/ktsu-dev/UndoRedo)|![GitHub Version](https://img.shields.io/github/v/release/ktsu-dev/UndoRedo?label=&logo=github)| | |![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/UndoRedo?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/UndoRedo/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[UniversalSerializer](https://github.com/ktsu-dev/UniversalSerializer)|![NuGet Version](https://img.shields.io/nuget/v/ktsu.UniversalSerializer?label=&logo=nuget)| |![NuGet Downloads](https://img.shields.io/nuget/dt/ktsu.UniversalSerializer?label=&logo=nuget)|![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/UniversalSerializer?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/UniversalSerializer/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|

### Applications

| Repo | Stable | Prerelease | Downloads | Activity | Status | README |
|------|--------|------------|-----------|----------|--------|--------|
|[BlastMerge](https://github.com/ktsu-dev/BlastMerge)|![NuGet Version](https://img.shields.io/nuget/v/ktsu.BlastMerge?label=&logo=nuget)| |![NuGet Downloads](https://img.shields.io/nuget/dt/ktsu.BlastMerge?label=&logo=nuget)|![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/BlastMerge?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/BlastMerge/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[BuildMonitor](https://github.com/ktsu-dev/BuildMonitor)|![GitHub Version](https://img.shields.io/github/v/release/ktsu-dev/BuildMonitor?label=&logo=github)| | |![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/BuildMonitor?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/BuildMonitor/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[Coder](https://github.com/ktsu-dev/Coder)|![GitHub Version](https://img.shields.io/github/v/release/ktsu-dev/Coder?label=&logo=github)| | |![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/Coder?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/Coder/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[CrossRepoActions](https://github.com/ktsu-dev/CrossRepoActions)|![GitHub Version](https://img.shields.io/github/v/release/ktsu-dev/CrossRepoActions?label=&logo=github)| | |![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/CrossRepoActions?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/CrossRepoActions/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[IconHelper](https://github.com/ktsu-dev/IconHelper)|![GitHub Version](https://img.shields.io/github/v/release/ktsu-dev/IconHelper?label=&logo=github)| | |![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/IconHelper?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/IconHelper/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|
|[ProjectDirector](https://github.com/ktsu-dev/ProjectDirector)|![GitHub Version](https://img.shields.io/github/v/release/ktsu-dev/ProjectDirector?label=&logo=github)| | |![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/ProjectDirector?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/ProjectDirector/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/failing-red?label=&logo=mdbook)|
|[SyncFileContents](https://github.com/ktsu-dev/SyncFileContents)|![GitHub Version](https://img.shields.io/github/v/release/ktsu-dev/SyncFileContents?label=&logo=github)| | |![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ktsu-dev/SyncFileContents?label=&logo=github)|![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ktsu-dev/SyncFileContents/dotnet.yml?label=&logo=github)|![README](https://img.shields.io/badge/passing-brightgreen?label=&logo=mdbook)|

