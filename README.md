# bytesized.co
Source for [bytesized.co](https://www.bytesized.co).

bytesized.co is statically generated using [Publish](https://github.com/JohnSundell/Publish), a static site generator written in Swift.

## Publishing to S3
```
swift run -c release
aws s3 sync Output/. s3://<Bucket> --exclude "*.DS_Store*"
```
