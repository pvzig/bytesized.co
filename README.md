# bytesized.co
Source for [bytesized.co](https://www.bytesized.co).

bytesized.co is statically generated using [Publish](https://github.com/JohnSundell/Publish), a static site generator written in Swift.

## Local Development

The repo-root `justfile` is the preferred entry point for common local tasks.

Install the `just` task runner if you do not already have it:

```bash
brew install just
```

For local setup, copy [`.ENV.example`](.ENV.example) to `.ENV` and fill in the values used by the local stack.

### Site Generator
```bash
just site
```

### Full Local Stack
To rebuild the SwiftWASM app, regenerate the site with a localhost backend URL, run the backend, and serve `Output/` in one command:

```bash
just local
```
`just local` requires the following `.ENV` values:
```
- SITE_HOST
- SITE_PORT
- BACKEND_HOST
- BACKEND_PORT
- GENERATED_IMAGES_BUCKET
- OPENAI_API_KEY
- OPENAI_IMAGE_MODEL
- IMAGE_GEN_PREFIX
- AWS_REGION
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
```

### SwiftWASM App
- The SwiftWASM package lives in `BytesizedCafe/`
- The app is built with JavaScriptKit's `PackageToJS` SwiftPM plugin
- The page loads `/bytesized-cafe-app/index.js` directly as a module with the request/render logic lives in the SwiftWASM target

To build the SwiftWASM app before generating the site:
1. Install a WebAssembly Swift SDK first by following the official guide: https://www.swift.org/documentation/articles/wasm-getting-started.html
2. Install Binaryen if you want `wasm-opt` optimizations during packaging

```bash
just wasm
```
which runs:

```bash
swift package --swift-sdk <swift-sdk-id> js --product BytesizedCafe -c release --use-cdn
```

It copies the generated package output from `BytesizedCafe/.build/plugins/PackageToJS/outputs/Package/` into the repo-root `bytesized-cafe-app/` folder, which the site generator then publishes at `/bytesized-cafe-app/`.

### Hummingbird Backend
Run the backend from `Backend/` with your generated-images bucket and OpenAI key configured:

```bash
cd Backend
HOST=127.0.0.1 \
PORT=8080 \
GENERATED_IMAGES_BUCKET=<generated-images-bucket> \
OPENAI_API_KEY=<key> \
OPENAI_IMAGE_MODEL=<model> \
IMAGE_GEN_PREFIX=<prefix> \
AWS_REGION=<region> \
AWS_ACCESS_KEY_ID=<key-id> \
AWS_SECRET_ACCESS_KEY=<secret> \
swift run Server
```
Image generation is capped at 15 images per UTC day. The backend stores a stable per-page image key so repeat requests for the same page reuse the existing image instead of generating again. When the daily budget is exhausted for a first-time page request, the server assigns that page a random previously generated image.
Freshly generated image keys are still partitioned by UTC date under `IMAGE_GEN_PREFIX/YYYY/MM/DD/`, and the stable page cache lives under `IMAGE_GEN_PREFIX/page-cache/`.

Point the site generator at the backend API when building the HTML:

```bash
just site-local
```

That recipe requires `BYTESIZED_CAFE_API_URL`, for example `BYTESIZED_CAFE_API_URL=http://127.0.0.1:8080/api/cafe/generate just site-local`.

### Railway Deployment
Production deployment runs from [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml) when you push to the deployment branch.

The backend job runs on `ubuntu-latest`, syncs Railway runtime variables from GitHub Actions, and then deploys `Backend/` to Railway with `railway up Backend --ci --path-as-root`. It uses the checked-in [`Backend/railway.toml`](Backend/railway.toml), [`Backend/Dockerfile`](Backend/Dockerfile), and [`Scripts/sync-railway-backend-variables.sh`](Scripts/sync-railway-backend-variables.sh) for build and deploy configuration. Railway owns the runtime container and public HTTPS endpoint.

Create one empty Railway service for the backend. Disable Railway’s own GitHub autodeploy for the service so pushes do not trigger duplicate backend deployments. The deploy workflow syncs these runtime variables into Railway before each deployment:
- `GENERATED_IMAGES_BUCKET`
- `OPENAI_API_KEY`
- `OPENAI_IMAGE_MODEL`
- `IMAGE_GEN_PREFIX`
- `AWS_REGION`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

To seed the overlapping GitHub Actions repository variables and secrets from the local [`.ENV`](.ENV), run:

```bash
./Scripts/sync-github-actions-config.sh
```

That script syncs `AWS_REGION`, `GENERATED_IMAGES_BUCKET`, `OPENAI_IMAGE_MODEL`, `IMAGE_GEN_PREFIX`, `AWS_S3_BUCKET`, `OPENAI_API_KEY`, `AWS_ACCESS_KEY_ID`, and `AWS_SECRET_ACCESS_KEY` using `gh`, streaming secret values over stdin so they do not appear in command arguments.

Set these GitHub Actions repository variables:
- `RAILWAY_PROJECT_ID`
- `RAILWAY_ENVIRONMENT_NAME`
- `RAILWAY_SERVICE_NAME`
- `BYTESIZED_CAFE_API_URL` (your backend domain)
- `AWS_REGION`
- `GENERATED_IMAGES_BUCKET`
- `OPENAI_IMAGE_MODEL`
- `IMAGE_GEN_PREFIX`
and these GitHub Actions secrets:
- `RAILWAY_TOKEN`
- `OPENAI_API_KEY`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_S3_BUCKET`

For local Docker validation and GitHub workflow linting, run:

```bash
just validate-deployment
```

That builds the backend Docker image locally and validates GitHub Actions workflow YAML parsing.
The GitHub Actions validation workflow uses the same `just validate-deployment` recipe.
