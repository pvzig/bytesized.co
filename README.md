# bytesized.co
Source for [bytesized.co](https://www.bytesized.co).

bytesized.co is statically generated using [Publish](https://github.com/JohnSundell/Publish), a static site generator written in Swift.

## Publishing to S3

Manually:
```bash
swift run -c release bytesized
swift run -c release bytesized --deploy
```

With [Github Actions](https://github.com/pvzig/bytesized.co/blob/master/.github/workflows/deploy.yml):

Configure the following secrets in Github (/repo/settings/secrets)
- AWS_S3_BUCKET
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
