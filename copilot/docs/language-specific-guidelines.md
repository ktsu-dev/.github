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

## Markdown Guidelines

- Use `markdownlint --fix <path-to-markdown-files>` to automatically fix any linting issues in markdown files

## Related Resources

- [Coding Guidelines](coding-guidelines.md)
- [Documentation Guidelines](documentation-guidelines.md)

[Back to Main Instructions](main-instructions.md)
