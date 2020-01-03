cd /Sites/bytesized.co/
spelt build
cd _build
aws s3 sync . s3://bytesized.co/ --exclude "*.DS_Store*"