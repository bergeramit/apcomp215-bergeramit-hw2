# Overview

Your Docker Hub image URL: https://hub.docker.com/repository/docker/aberger1337/pavlos-cheese-mcp2
Your Cloud Run service URL: https://pavlos-cheese-mcp2-1097076476714.europe-west1.run.app

# How to run

## Step 1

Implemented simple MCP server in server.py

## Step 2 Build and Run part1 locally
```
# Build the image
docker build -t pavlos-cheese-mcp .

# Run locally
docker run -p 8080:8080 pavlos-cheese-mcp
```

## Push to Docekr hub

```
# setup google cloud docker credentials
gcloud auth configure-docker

# For cloud run must support linux/amd64 deployment
docker build --platform linux/amd64 -t aberger1337/pavlos-cheese-mcp:latest .

# Login to Docker hub
docker login

# Tagging the image with my username and latest
docker tag pavlos-cheese-mcp aberger1337/pavlos-cheese-mcp:latest

# Pushing the image to dockerhub
docker push aberger1337/pavlos-cheese-mcp:latest
```

### Cloud Run Failed due to Unknown platform not linux/amd64

The fix:
```
# Create a new manifest list with only the amd64 entry
docker manifest create aberger1337/pavlos-cheese-mcp:latest \
  aberger1337/pavlos-cheese-mcp@sha256:298f34ad1fef931c1dd42154e97934a92e52fade3315483b49b3e536229110b0

# Annotate it with the correct platform
docker manifest annotate aberger1337/pavlos-cheese-mcp:latest \
  aberger1337/pavlos-cheese-mcp@sha256:298f34ad1fef931c1dd42154e97934a92e52fade3315483b49b3e536229110b0 \
  --os linux --arch amd64

# Push the updated manifest
docker manifest push aberger1337/pavlos-cheese-mcp:latest

# Finally:
sha256:0a3f7ea4dd17c0308599f7786f546a5516844ba7314e89572cdd2d80f66f67fb
(part1) amitberger@Amits-MacBook-Pro part1 % docker manifest inspect aberger1337/pavlos-cheese-mcp2:latest
{
   "schemaVersion": 2,
   "mediaType": "application/vnd.oci.image.index.v1+json",
   "manifests": [
      {
         "mediaType": "application/vnd.oci.image.manifest.v1+json",
         "size": 2005,
         "digest": "sha256:298f34ad1fef931c1dd42154e97934a92e52fade3315483b49b3e536229110b0",
         "platform": {
            "architecture": "amd64",
            "os": "linux"
         }
      }
   ]
}
```

