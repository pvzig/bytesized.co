# AGENTS.md

Instructions for coding agents working on this repo.
## General
- When adding new dependencies, check Github to make sure that you’re adding them at the latest release.
- When naming files/targets, prefer non-project namespaced names (eg Server vs BytesizedServer)
## Validating Changes
- Run the swift-format skill
- Run `./Scripts/validate-deployment-config.sh` when changing `Backend/Dockerfile`, `.github/workflows`, or deployment-related scripts
- Keep `SPEC.md` up-to-date when making changes.
- You don't need to run swift-format and swift-test to validate changes to markdown files.

## Build & Run Commands
- List available recipes: `just help`
- Build the WebAssembly app: `just wasm`
- Build site: `just site`
- Build with release config: `just site-release`
- Build site against a configured local cafe API: `just site-local`
- Run local stack: `just local`
- Run backend only: `just backend`
- Validate deployment config: `just validate-deployment`
- Deploy site to S3: `just site-deploy`

`just` loads environment variables from `.ENV` automatically.

## Project Structure
- `Sources/bytesized/`: Swift source files
- `Content/posts/`: Markdown blog posts
- `Resources/`: Static assets (CSS, fonts, images)
- `Output/`: Generated site (not checked in)

## Content Writing
- Use Markdown for all content in the Content/posts directory
- Include proper metadata with title, date, and path

## Code Style Guidelines
- Swift 6.2+ codebase using the Publish framework
- Use descriptive variable/function names in camelCase
- Consistent 4-space indentation 
- Prefer `Struct` to `Enum` for general data structures
- Group extensions with the type they extend
- Use Swift's strong type system
- Organize imports alphabetically: Foundation first, then third-party
- Keep functions small and focused on a single responsibility
- Use Swift's error handling with do/try/catch
- Follow CommonMark for Markdown content
- Use the `swift-concurrency` skill for Swift concurrency guidance.
- Always mark @Observable classes with @MainActor.
- Assume strict Swift concurrency rules are being applied.
- Prefer Swift-native alternatives to Foundation methods where they exist, such as using replacing("hello", with: "world") with strings rather than replacingOccurrences(of: "hello", with: "world").
- Prefer modern Foundation API, for example URL.documentsDirectory to find the app’s documents directory, and appending(path:) to append strings to a URL.
- Never use C-style number formatting such as Text(String(format: "%.2f", abs(myNumber))); always use Text(abs(change), format: .number.precision(.fractionLength(2))) instead.
- Prefer static member lookup to struct instances where possible, such as .circle rather than Circle(), and .borderedProminent rather than BorderedProminentButtonStyle().
- Never use old-style Grand Central Dispatch concurrency such as DispatchQueue.main.async(). If behavior like this is needed, always use modern Swift concurrency.
- Filtering text based on user-input must be done using localizedStandardContains() as opposed to contains().
- Avoid force unwraps and force try unless it is unrecoverable.

## Tools
- Prefer `ast-grep` for syntax-aware searches; only use `rg` for plain-text matching when needed.
- Use the `gh` CLI for GitHub operations when available (e.g., creating repos and pushing).
