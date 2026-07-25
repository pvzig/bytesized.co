# bytesized.co Specification

## Purpose

`bytesized.co` is a Swift-generated static site deployed to Amazon S3 and served
through CloudFront.

## Project Layout

- `Sources/bytesized/` contains the Swift site generator.
- `Content/posts/` contains Markdown posts and their metadata.
- `Resources/` contains static CSS, fonts, and images.
- `Output/` is generated deployment output and is not committed.

## Deployment

The `Build and Deploy` GitHub Actions workflow is the production deployment
entry point.

- A push to the default `main` branch triggers deployment.
- The build job runs the Swift site generator in release mode and uploads the
  generated `Output/` directory as an artifact.
- The deploy job downloads that artifact, synchronizes it to the configured S3
  bucket, and invalidates the relevant CloudFront paths.
- Deployment credentials and destination identifiers are supplied through
  GitHub Actions secrets.

## Validation

Deployment workflow changes must keep the trigger aligned with the repository's
default branch and leave the workflow valid YAML. This historical revision does
not contain `Scripts/validate-deployment-config.sh`, so workflow validation is
performed with a YAML parser and by confirming GitHub recognizes the workflow
after it is pushed.
