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

- **[ThemeProvider](https://github.com/ktsu-dev/ThemeProvider)**: theme management and styling using color science and semantic remapping
- **[ImGuiProvider](https://github.com/ktsu-dev/ImGuiProvider)**: ImGui abstraction layer for backend-independent UI code

### UI and Tools

- **[ImGuiApp](https://github.com/ktsu-dev/ImGuiApp)**: Dear ImGui application scaffolding, widgets, modal dialogs, and styling
- **[BlastMerge](https://github.com/ktsu-dev/BlastMerge)**: cross-repository file synchronization through iterative merging with interactive conflict resolution

### Utilities

- **[Extensions](https://github.com/ktsu-dev/Extensions)**: extension methods that cover the gaps in the base class library
- **[AppDataStorage](https://github.com/ktsu-dev/AppDataStorage)**: persistent application data with automatic file management, debounced saves, and backup recovery
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
dotnet add package ktsu.Extensions
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
    "version": "10.0.100",
    "rollForward": "latestFeature"
  },
  "msbuild-sdks": {
    "MSTest.Sdk": "4.3.3",
    "ktsu.Sdk": "2.28.0",
    "ktsu.Sdk.ConsoleApp": "2.28.0",
    "ktsu.Sdk.Tool": "2.28.0",
    "ktsu.Sdk.App": "2.28.0"
  }
}
```

## Project Status

| Repo | Ships | Stable | Prerelease | winget | SDK | Activity | Status | README |
|------|-------|--------|------------|--------|-----|----------|--------|--------|
|[AppDataStorage](https://github.com/ktsu-dev/AppDataStorage)|![lib](https://img.shields.io/badge/-lib-004880)|![NuGet Version](https://img.shields.io/badge/-v1.16.46-004880?logo=nuget&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-94-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[BlastMerge](https://github.com/ktsu-dev/BlastMerge)|![lib](https://img.shields.io/badge/-lib-004880)![cli](https://img.shields.io/badge/-cli-3B3B3B)|![NuGet Version](https://img.shields.io/badge/-v1.1.4-004880?logo=nuget&logoColor=white)| |![winget](https://img.shields.io/badge/-v1.0.21-0078D4?logo=windows&logoColor=white)|![SDK](https://img.shields.io/badge/-2.25.0-dbab09)|![Activity](https://img.shields.io/badge/-38-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-failing-d73a4a?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[BuildMonitor](https://github.com/ktsu-dev/BuildMonitor)|![app](https://img.shields.io/badge/-app-68217A)|![GitHub Version](https://img.shields.io/badge/-v1.5.1-181717?logo=github&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-100-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[CaseConverter](https://github.com/ktsu-dev/CaseConverter)|![lib](https://img.shields.io/badge/-lib-004880)|![NuGet Version](https://img.shields.io/badge/-v1.3.35-004880?logo=nuget&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-70-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[CodeBlocker](https://github.com/ktsu-dev/CodeBlocker)|![lib](https://img.shields.io/badge/-lib-004880)|![NuGet Version](https://img.shields.io/badge/-v2.0.1-004880?logo=nuget&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-94-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[Coder](https://github.com/ktsu-dev/Coder)|![lib](https://img.shields.io/badge/-lib-004880)![cli](https://img.shields.io/badge/-cli-3B3B3B)![app](https://img.shields.io/badge/-app-68217A)|![GitHub Version](https://img.shields.io/badge/-v1.0.10-181717?logo=github&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.25.0-dbab09)|![Activity](https://img.shields.io/badge/-39-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[Containers](https://github.com/ktsu-dev/Containers)|![lib](https://img.shields.io/badge/-lib-004880)|![NuGet Version](https://img.shields.io/badge/-v1.1.16-004880?logo=nuget&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-70-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[CredentialCache](https://github.com/ktsu-dev/CredentialCache)|![lib](https://img.shields.io/badge/-lib-004880)|![NuGet Version](https://img.shields.io/badge/-v1.3.31-004880?logo=nuget&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-93-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[DeepClone](https://github.com/ktsu-dev/DeepClone)|![lib](https://img.shields.io/badge/-lib-004880)|![NuGet Version](https://img.shields.io/badge/-v2.0.29-004880?logo=nuget&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-67-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[DelegateTransform](https://github.com/ktsu-dev/DelegateTransform)|![lib](https://img.shields.io/badge/-lib-004880)|![NuGet Version](https://img.shields.io/badge/-v1.1.27-004880?logo=nuget&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-80-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[Essentials](https://github.com/ktsu-dev/Essentials)|![lib](https://img.shields.io/badge/-lib-004880)|![NuGet Version](https://img.shields.io/badge/-v2.3.1-004880?logo=nuget&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-90-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-failing-d73a4a?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[Extensions](https://github.com/ktsu-dev/Extensions)|![lib](https://img.shields.io/badge/-lib-004880)|![NuGet Version](https://img.shields.io/badge/-v1.6.8-004880?logo=nuget&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-69-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[FileDeduplicator](https://github.com/ktsu-dev/FileDeduplicator)|![cli](https://img.shields.io/badge/-cli-3B3B3B)|![GitHub Version](https://img.shields.io/badge/-v1.1.1-181717?logo=github&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-86-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[Frontmatter](https://github.com/ktsu-dev/Frontmatter)|![lib](https://img.shields.io/badge/-lib-004880)|![NuGet Version](https://img.shields.io/badge/-v1.2.23-004880?logo=nuget&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-80-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[FuzzySearch](https://github.com/ktsu-dev/FuzzySearch)|![lib](https://img.shields.io/badge/-lib-004880)|![NuGet Version](https://img.shields.io/badge/-v1.2.38-004880?logo=nuget&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-65-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[GitBranchStateCache](https://github.com/ktsu-dev/GitBranchStateCache)|![lib](https://img.shields.io/badge/-lib-004880)![tool](https://img.shields.io/badge/-tool-512BD4)|![NuGet Version](https://img.shields.io/badge/-v1.0.7-004880?logo=nuget&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-34-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[GitIntegration](https://github.com/ktsu-dev/GitIntegration)|![lib](https://img.shields.io/badge/-lib-004880)|![NuGet Version](https://img.shields.io/badge/-v2.5.3-004880?logo=nuget&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.25.0-dbab09)|![Activity](https://img.shields.io/badge/-100-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[GitLfsCache](https://github.com/ktsu-dev/GitLfsCache)|![lib](https://img.shields.io/badge/-lib-004880)![tool](https://img.shields.io/badge/-tool-512BD4)|![NuGet Version](https://img.shields.io/badge/-v1.8.9-004880?logo=nuget&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-85-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[IconHelper](https://github.com/ktsu-dev/IconHelper)|![app](https://img.shields.io/badge/-app-68217A)|![GitHub Version](https://img.shields.io/badge/-v1.4.15-181717?logo=github&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-95-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[ImageDescriber](https://github.com/ktsu-dev/ImageDescriber)|![cli](https://img.shields.io/badge/-cli-3B3B3B)|![GitHub Version](https://img.shields.io/badge/-v1.1.84-181717?logo=github&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-98-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[ImGuiApp](https://github.com/ktsu-dev/ImGuiApp)|![lib](https://img.shields.io/badge/-lib-004880)|![NuGet Version](https://img.shields.io/badge/-v2.1.7-004880?logo=nuget&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-100-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[ImGuiCredentialPopups](https://github.com/ktsu-dev/ImGuiCredentialPopups)|![lib](https://img.shields.io/badge/-lib-004880)|![NuGet Version](https://img.shields.io/badge/-v1.2.1-004880?logo=nuget&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-100-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[ImGuiProvider](https://github.com/ktsu-dev/ImGuiProvider)|![lib](https://img.shields.io/badge/-lib-004880)|![NuGet Version](https://img.shields.io/badge/-v1.1.23-004880?logo=nuget&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-68-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[IntervalAction](https://github.com/ktsu-dev/IntervalAction)|![lib](https://img.shields.io/badge/-lib-004880)|![NuGet Version](https://img.shields.io/badge/-v1.3.40-004880?logo=nuget&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-70-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[Invoker](https://github.com/ktsu-dev/Invoker)|![lib](https://img.shields.io/badge/-lib-004880)|![NuGet Version](https://img.shields.io/badge/-v1.2.25-004880?logo=nuget&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-69-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[JsonRequiredConditionally](https://github.com/ktsu-dev/JsonRequiredConditionally)|![lib](https://img.shields.io/badge/-lib-004880)|![NuGet Version](https://img.shields.io/badge/-v1.2.1-004880?logo=nuget&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-100-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[Keybinding](https://github.com/ktsu-dev/Keybinding)|![lib](https://img.shields.io/badge/-lib-004880)|![GitHub Version](https://img.shields.io/badge/-v1.0.37-181717?logo=github&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-93-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[KtsuBuild](https://github.com/ktsu-dev/KtsuBuild)|![lib](https://img.shields.io/badge/-lib-004880)![tool](https://img.shields.io/badge/-tool-512BD4)|![NuGet Version](https://img.shields.io/badge/-v2.10.0-004880?logo=nuget&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-100-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[KtsuTools](https://github.com/ktsu-dev/KtsuTools)|![lib](https://img.shields.io/badge/-lib-004880)![cli](https://img.shields.io/badge/-cli-3B3B3B)|![GitHub Version](https://img.shields.io/badge/-v1.1.0-181717?logo=github&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-79-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[Navigation](https://github.com/ktsu-dev/Navigation)|![lib](https://img.shields.io/badge/-lib-004880)|![NuGet Version](https://img.shields.io/badge/-v1.0.24-004880?logo=nuget&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-63-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[NJsonSchemaJsonConverter](https://github.com/ktsu-dev/NJsonSchemaJsonConverter)|![lib](https://img.shields.io/badge/-lib-004880)|![NuGet Version](https://img.shields.io/badge/-v1.0.41-004880?logo=nuget&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-67-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[PreciseNumber](https://github.com/ktsu-dev/PreciseNumber)|![lib](https://img.shields.io/badge/-lib-004880)|![NuGet Version](https://img.shields.io/badge/-v1.7.34-004880?logo=nuget&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-68-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[ProjectDirector](https://github.com/ktsu-dev/ProjectDirector)|![app](https://img.shields.io/badge/-app-68217A)|![GitHub Version](https://img.shields.io/badge/-v1.2.1-181717?logo=github&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-99-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[RoundTripStringJsonConverter](https://github.com/ktsu-dev/RoundTripStringJsonConverter)|![lib](https://img.shields.io/badge/-lib-004880)|![NuGet Version](https://img.shields.io/badge/-v1.0.48-004880?logo=nuget&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-87-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[RunCommand](https://github.com/ktsu-dev/RunCommand)|![lib](https://img.shields.io/badge/-lib-004880)|![NuGet Version](https://img.shields.io/badge/-v1.5.8-004880?logo=nuget&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-87-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[Schema](https://github.com/ktsu-dev/Schema)|![lib](https://img.shields.io/badge/-lib-004880)![cli](https://img.shields.io/badge/-cli-3B3B3B)![app](https://img.shields.io/badge/-app-68217A)|![NuGet Version](https://img.shields.io/badge/-v1.10.0-004880?logo=nuget&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-100-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-failing-d73a4a?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[ScopedAction](https://github.com/ktsu-dev/ScopedAction)|![lib](https://img.shields.io/badge/-lib-004880)|![NuGet Version](https://img.shields.io/badge/-v1.1.35-004880?logo=nuget&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-73-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[Semantics](https://github.com/ktsu-dev/Semantics)|![lib](https://img.shields.io/badge/-lib-004880)|![NuGet Version](https://img.shields.io/badge/-v1.0.20-004880?logo=nuget&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-100-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[SignificantNumber](https://github.com/ktsu-dev/SignificantNumber)|![lib](https://img.shields.io/badge/-lib-004880)|![NuGet Version](https://img.shields.io/badge/-v1.4.36-004880?logo=nuget&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-79-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[SingleAppInstance](https://github.com/ktsu-dev/SingleAppInstance)|![lib](https://img.shields.io/badge/-lib-004880)|![NuGet Version](https://img.shields.io/badge/-v1.3.53-004880?logo=nuget&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-91-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[Sorting](https://github.com/ktsu-dev/Sorting)|![lib](https://img.shields.io/badge/-lib-004880)|![NuGet Version](https://img.shields.io/badge/-v1.0.31-004880?logo=nuget&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-69-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[SvnToGit](https://github.com/ktsu-dev/SvnToGit)|![lib](https://img.shields.io/badge/-lib-004880)![cli](https://img.shields.io/badge/-cli-3B3B3B)|![GitHub Version](https://img.shields.io/badge/-v1.0.24-181717?logo=github&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-73-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-failing-d73a4a?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[TextFilter](https://github.com/ktsu-dev/TextFilter)|![lib](https://img.shields.io/badge/-lib-004880)|![NuGet Version](https://img.shields.io/badge/-v1.5.42-004880?logo=nuget&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-77-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[ThemeProvider](https://github.com/ktsu-dev/ThemeProvider)|![lib](https://img.shields.io/badge/-lib-004880)![app](https://img.shields.io/badge/-app-68217A)|![NuGet Version](https://img.shields.io/badge/-v3.0.11-004880?logo=nuget&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-100-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[TUI](https://github.com/ktsu-dev/TUI)|![lib](https://img.shields.io/badge/-lib-004880)![cli](https://img.shields.io/badge/-cli-3B3B3B)|![GitHub Version](https://img.shields.io/badge/-v1.0.51-181717?logo=github&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-69-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|
|[UndoRedo](https://github.com/ktsu-dev/UndoRedo)|![lib](https://img.shields.io/badge/-lib-004880)|![GitHub Version](https://img.shields.io/badge/-v1.0.18-181717?logo=github&logoColor=white)| | |![SDK](https://img.shields.io/badge/-2.28.0-2ea44f)|![Activity](https://img.shields.io/badge/-66-181717?logo=github&logoColor=white)|![Status](https://img.shields.io/badge/-passing-2ea44f?logo=github&logoColor=white)|![README](https://img.shields.io/badge/-passing-2ea44f?logo=mdbook&logoColor=white)|

