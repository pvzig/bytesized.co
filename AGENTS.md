# AGENTS.md

Instructions for coding agents working on this repo.
## Validating Changes
- Run `./Scripts/validate-deployment-config.sh` when changing `Backend/Dockerfile`, `.github/workflows`, or deployment-related scripts
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
