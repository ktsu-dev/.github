# Language-Specific Guidelines

## .NET/C# Guidelines

- Use the latest stable version of .NET and C# as specified in the project
- Follow the official C# coding conventions and guidelines
- Use any specialized tools you have access to for building, testing, and running the project, but you can fall back to the .NET CLI if you have tried everything else and it still doesn't work
- Use `dotnet format` to format the code according to the project's style guidelines
- Before trying to fix any build errors, use the .NET format tool to format the code according to the project's style guidelines and check again to see if the errors persist
- Use `mstest` when writing unit tests
- Use `dotnet test -m:1` when running tests to limit the number of parallel test runs to 1, which can help with debugging and resource management
- Use `dotnet test -m:1 --collect:"XPlat Code Coverage"` to collect code coverage data for the tests
- Check if `Directory.Build.targets` has the required references before adding new references to the project file
- Review test results and coverage reports to identify areas for improvement

### .NET Naming Conventions

#### Specific Naming Patterns

| Type | Pattern | Examples |
|------|---------|----------|
| Namespace | PascalCase | `System.Collections` |
| Class/Struct | PascalCase | `StringBuilder`, `ValueType` |
| Interface | PascalCase with "I" prefix | `IDisposable`, `ICollection` |
| Method | PascalCase | `GetValue`, `CalculateTotal` |
| Property | PascalCase | `ItemCount`, `FirstName` |
| Event | PascalCase | `ValueChanged`, `ButtonClicked` |
| Field (public) | PascalCase | `ConnectionString` |
| Field (private/protected) | camelCase | `firstName`, `items` |
| Parameter/Local variable | camelCase | `customerName`, `orderTotal` |
| Enum type | PascalCase (singular) | `FileMode`, `ConnectionState` |
| Enum values | PascalCase | `ReadOnly`, `Connecting` |
| Constant | PascalCase | `MaxValue`, `DefaultTimeout` |
| Generic type parameter | PascalCase with "T" prefix | `TKey`, `TValue` |
| Delegate | PascalCase | `EventHandler`, `Func<T>` |
| Boolean variables/properties | PascalCase with "Is/Has/Can/Should" prefix | `IsVisible`, `HasChildren`, `CanExecute` |

#### Asynchronous Method Naming

- Append the suffix "Async" to method names that return a `Task` or `Task<T>`
- Example: `GetDataAsync()`, `SaveChangesAsync()`

#### Collection Naming

- Use plural nouns for collections
- Examples: `Users`, `OrderItems`, `CustomerList`

#### Exception Naming

- Suffix with "Exception"
- Examples: `ArgumentNullException`, `InvalidOperationException`

## PowerShell Guidelines

- Always use approved PowerShell verbs in function names (e.g., `Get-`, `Set-`, `New-`, `Remove-`)
- Verify verb usage with `Get-Verb` cmdlet before creating new functions
- Common approved verb groups and examples:
  - **Data**: `Get-`, `Import-`, `Export-`, `ConvertTo-`, `ConvertFrom-`
  - **Lifecycle**: `New-`, `Start-`, `Stop-`, `Restart-`, `Remove-`
  - **Modification**: `Add-`, `Set-`, `Update-`, `Rename-`, `Clear-`
  - **Security**: `Grant-`, `Revoke-`, `Protect-`, `Unprotect-`
  - **Communication**: `Connect-`, `Disconnect-`, `Send-`, `Receive-`
  - **Diagnostic**: `Test-`, `Trace-`, `Debug-`, `Measure-`
- Use PascalCase for function, parameter, and variable names
- Use singular nouns for cmdlet names (`Get-Item` not `Get-Items`)
- Avoid using aliases in scripts intended for sharing or production
- Include comment-based help for all functions with description, parameters, and examples

## Markdown Guidelines

- Use `markdownlint --fix <path-to-markdown-files>` to automatically fix any linting issues in markdown files and report any remaining issues
- Check for the existence of a `.markdownlint.json` file in the directory hierarchy. If it exists, use it to guide your style when writing markdown files. If it doesn't exist copy it from the .github directory in the workspace to the root of the project directory and use it as a template for your own markdownlint configuration
