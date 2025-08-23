# workflows-containers

Reusable GitHub Actions workflows for building and publishing Docker container images to container registries.

## publish.yaml

This workflow automates the process of building Docker images from one or more Dockerfiles and pushing them to a container registry (GitHub Container Registry by default). It supports:

- Building multiple Docker images in parallel
- Customizing image names with prefixes and postfixes
- Automatic tagging based on Git references
- Build caching for faster builds
- Flexible registry configuration

### Usage

To use this workflow in your repository, create a workflow file (e.g., `.github/workflows/build.yaml`) with the following content:

```yaml
name: Build and Publish Container

on:
  push:
    branches: [ main ]
    tags: [ 'v*' ]

jobs:
  publish:
    uses: unbounded-tech/workflows-containers/.github/workflows/publish.yaml@main
```

### Basic Example

This example builds and pushes a Docker image using the default Dockerfile in the repository root:

```yaml
jobs:
  publish:
    uses: unbounded-tech/workflows-containers/.github/workflows/publish.yaml@main
```

### Multiple Dockerfiles Example

This example builds and pushes multiple Docker images from different Dockerfiles:

```yaml
jobs:
  publish:
    uses: unbounded-tech/workflows-containers/.github/workflows/publish.yaml@main
    with:
      dockerfiles: |
        [
          {"dockerfile":"./Dockerfile","context":".","prefix":"","postfix":""},
          {"dockerfile":"./api/Dockerfile","context":"./api","prefix":"api-","postfix":""},
          {"dockerfile":"./worker/Dockerfile","context":"./worker","prefix":"","postfix":"-worker"}
        ]
```

### Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `docker_username` | Docker username for registry login | No | `github.actor` |
| `dockerfiles` | JSON array of objects with dockerfile path, context, prefix and postfix | No | `[{"dockerfile":"./Dockerfile","context":".","prefix":"","postfix":""}]` |
| `push` | Whether to push the Docker image | No | `true` |
| `registry` | The container registry to push to | No | `ghcr.io` |

#### Dockerfile Configuration

The `dockerfiles` input accepts a JSON array of objects with the following properties:

- `dockerfile`: Path to the Dockerfile (required)
- `context`: Build context path (defaults to `.`)
- `prefix`: Prefix for the image name (defaults to `""`)
- `postfix`: Postfix for the image name (defaults to `""`)

The resulting image name will be: `registry/owner/prefix-reponame-postfix:tag`

### Secrets

| Secret | Description | Required | Default |
|--------|-------------|----------|---------|
| `docker_password` | Docker password for registry login | No | `GITHUB_TOKEN` |

### How It Works

The workflow consists of two jobs:

1. **setup**: Processes the `dockerfiles` input to handle simplified specifications
2. **publish-container**: Builds and pushes Docker images based on the processed configurations

For each Dockerfile configuration, the workflow:

1. Checks out the repository
2. Sets up QEMU for multi-platform builds
3. Sets up Docker Buildx
4. Logs in to the specified container registry
5. Extracts metadata (tags, labels) for Docker
6. Logs the configuration details
7. Builds and optionally pushes the Docker image

### Custom Registry

To push to a custom registry:

```yaml
jobs:
  publish:
    uses: unbounded-tech/workflows-containers/.github/workflows/publish.yaml@main
    with:
      registry: docker.io
      docker_username: ${{ secrets.DOCKERHUB_USERNAME }}
    secrets:
      docker_password: ${{ secrets.DOCKERHUB_TOKEN }}
```

### Build Only (No Push)

To build the image without pushing:

```yaml
jobs:
  publish:
    uses: unbounded-tech/workflows-containers/.github/workflows/publish.yaml@main
    with:
      push: false
```

### Custom Image Naming

The workflow supports customizing image names with prefixes and postfixes:

```yaml
jobs:
  publish:
    uses: unbounded-tech/workflows-containers/.github/workflows/publish.yaml@main
    with:
      dockerfiles: |
        [
          {"dockerfile":"./Dockerfile","prefix":"service-","postfix":"-backend"}
        ]
```

This would result in an image named: `ghcr.io/owner/service-{{ reponame }}-backend:tag`

### Permissions

The workflow requires the following permissions:

- `packages: write` - For pushing to GitHub Container Registry
- `contents: write` - For accessing repository contents

These permissions are automatically set in the workflow.
