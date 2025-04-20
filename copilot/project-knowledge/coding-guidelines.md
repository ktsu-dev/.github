# General Coding Guidelines

## Best Practices

- Follow the coding guidelines and style guides defined in the project
- Follow best practices for code organization and structure
- Ensure code is modular and reusable where possible
- Keep functions and methods focused on a single responsibility
- Use meaningful variable and method names that convey their purpose
- Avoid using magic numbers or hard-coded values; use constants or configuration settings instead
- Use consistent naming conventions for variables, methods, and classes
- Use appropriate error handling and logging mechanisms
- Avoid using global variables or state where possible
- Use version control for all code changes and follow the project's branching and merging strategy
- Write clear and concise commit messages that describe the changes made
- Use pull requests for code reviews and collaboration
- Ensure code is well-tested and passes all unit tests before merging changes
- Use built-in language features and libraries over custom implementations unless necessary
- Use existing libraries and frameworks to avoid reinventing the wheel
- Use data type that convey semantics over primitive types (e.g., use `DateTime` instead of `long` for timestamps)
- Use enums over booleans for flags or options to improve semantics and readability
- Use language features that improve semantics, readability, and maintainability
- Use language features that improve performance and reduce complexity
- Use overloads over optional parameters to make interfaces clearer and more explicit
- Use classes or structures to pass multiple values instead of using tuples or arrays
- Use classes or structures to keep parameter counts low and improve readability

## Quality Standards

- Use the appropriate version of the programming language as specified in the project
- Follow official language-specific guidelines and best practices
- Ensure all dependencies are compatible with the specified version
- Follow the official language coding conventions and guidelines
- Use any project-wide settings defined in configuration files
- Use appropriate formatting tools to ensure code adheres to project style guidelines
- Use appropriate build commands to verify code compiles correctly
- Use appropriate testing commands to ensure code functions as expected
- Lines in code files should not contain trailing whitespace, especially blank lines

## Comment Guidelines

- Avoid using comments to explain simple or obvious code. The code should be self-explanatory, and comments should provide additional context or reasoning
- Avoid using comments to explain the purpose of a class or method. The class or method name should be descriptive enough to convey its purpose
- Write clear and concise comments to explain complex logic, important decisions or trade-offs, and any non-obvious behavior in the code
- Use comments to document any assumptions, limitations, or potential issues with the code
- Use TODO comments to indicate areas of the code that require further work or attention. They should be clear and specific, indicating what needs to be done and why
- Don't use journal-style comments (e.g., "Fix for issue #123") in the codebase, use version control to provide a history of changes and issues

## Naming Conventions

### General Principles

- Use clear, descriptive names that convey intent and purpose
- Prefer readability over brevity
- Use consistent capitalization based on the type of identifier
- Avoid abbreviations unless they would be well-known and understood by non-technical individuals or where they are a critical part of the domain language
- Do not use Hungarian notation
- Follow language-specific conventions for naming patterns (see language-specific guidelines)

### Standardized Verb Usage

When naming methods, use verbs that clearly communicate the action being performed. Here are standardized verbs and their appropriate usage patterns:

| Verb | Usage | Examples |
|------|-------|----------|
| `Get` | Returns data, doesn't modify state | `GetUser()`, `getBalance()` |
| `Set` | Assigns a value to a property | `SetName()`, `setConfiguration()` |
| `Add` | Adds an item to a collection | `AddUser()`, `addItem()` |
| `Remove` | Removes an item from a collection | `RemoveUser()`, `removeRange()` |
| `Delete` | Permanently destroys an object | `DeleteFile()`, `deleteRecord()` |
| `Clear` | Removes all items or resets state | `ClearList()`, `clearErrors()` |
| `Update` | Modifies an existing item | `UpdateProfile()`, `updateRecord()` |
| `Create` | Creates a new instance | `CreateOrder()`, `createFile()` |
| `Initialize` | Sets up initial state | `InitializeComponent()`, `initializeServices()` |
| `Open` | Opens a resource | `OpenConnection()`, `openFile()` |
| `Close` | Closes a resource | `CloseConnection()`, `closeFile()` |
| `Start` | Begins a process | `StartTransaction()`, `startService()` |
| `Stop` | Ends a process | `StopTimer()`, `stopService()` |
| `Send` | Transmits data | `SendMessage()`, `sendEmail()` |
| `Receive` | Accepts incoming data | `ReceiveMessage()`, `receiveData()` |
| `Find` | Searches and returns first match | `FindUserById()`, `findRecord()` |
| `Search` | Searches and returns all matches | `SearchCustomers()`, `searchFiles()` |
| `Save` | Persists data | `SaveChanges()`, `saveFile()` |
| `Load` | Retrieves stored data | `LoadConfiguration()`, `loadFile()` |
| `Validate` | Checks if something is valid | `ValidateInput()`, `validateEmail()` |
| `Can` | Checks if an operation is possible | `CanDelete()`, `canExecute()` |
| `Is` | Checks a condition | `IsValid()`, `isActive()` |
| `Has` | Checks if something contains/possesses | `HasPermission()`, `hasItems()` |
| `Should` | Checks if something ought to occur | `ShouldProcess()`, `shouldUpdate()` |
| `Calculate` | Performs computation | `CalculateTotal()`, `calculateAverage()` |
| `Parse` | Converts string to another type | `ParseInt()`, `parseDate()` |
| `Format` | Converts a type to string | `FormatDate()`, `formatCurrency()` |
| `Convert` | Changes from one type to another | `ConvertToDateTime()`, `convertToString()` |
| `Register` | Adds to a registry | `RegisterCallback()`, `registerClient()` |
| `Unregister` | Removes from a registry | `UnregisterCallback()`, `unregisterClient()` |
| `Subscribe` | Begins listening for events | `SubscribeToEvents()`, `subscribeToChannel()` |
| `Unsubscribe` | Stops listening for events | `UnsubscribeFromEvents()`, `unsubscribeFromChannel()` |
| `Try` | Attempts operation, returns success flag | `TryParse()`, `tryGetValue()` |
| `Ensure` | Guarantees a condition, may throw | `EnsureDirectoryExists()`, `ensureNotNull()` |

Note: The actual capitalization of methods should follow language-specific conventions. For example, in C# methods use PascalCase, while in JavaScript they typically use camelCase.

## Collection Naming

- Use plural nouns for collections
- Examples: `users`, `orderItems`, `customerList`

## Error Handling

- Use appropriate error handling mechanisms for the language
- Be explicit about error conditions and handle them appropriately
- Avoid swallowing exceptions without proper logging or handling
- Use meaningful error messages that help diagnose the problem
- Consider different error handling approaches based on the context:
  - Return error codes/objects where appropriate
  - Throw exceptions for exceptional conditions
  - Use result objects that can contain success/failure information
