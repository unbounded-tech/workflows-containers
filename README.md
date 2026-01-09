# workflows-containers

Reusable GitHub Actions workflows for building and publishing Docker container images to container registries.

## publish.yaml

This workflow automates the process of building Docker images from one or more Dockerfiles and pushing them to a container registry (GitHub Container Registry by default). It supports:

- Building multiple Docker images in parallel
- Customizing image names with prefixes and postfixes
- Automatic tagging based on Git references (branches, tags, PRs)
- Flexible tagging with SHA and branch-SHA combinations
- Build caching for faster builds
- Automatic PR comments with published image details
- Flexible registry configuration

### Usage

To use this workflow in your repository, create a workflow file (e.g., `.github/workflows/build.yaml`) with the following content:

```yaml
name: Build and Publish Container

on:
  push:
    branches: [main]
    tags: ['v*']
  pull_request:
    branches: [main]

jobs:
  publish:
    uses: unbounded-tech/workflows-containers/.github/workflows/publish.yaml@main
```

### Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `docker_username` | Docker username for registry login | No | `github.actor` |
| `dockerfiles` | JSON array of dockerfile configurations (see below) | No | `[{"dockerfile":"./Dockerfile","context":".","prefix":"","postfix":""}]` |
| `push` | Whether to push the Docker image | No | `true` |
| `registry` | The container registry to push to | No | `ghcr.io` |
| `tag_branch_on_pr` | Tag images with the branch name on PR events | No | `false` |
| `tag_sha` | Tag images with the commit SHA | No | `false` |
| `tag_branch_sha` | Tag images with `branch-sha` format | No | `false` |

### Secrets

| Secret | Description | Required | Default |
|--------|-------------|----------|---------|
| `docker_password` | Docker password for registry login | No | `GITHUB_TOKEN` |

### Tagging Behavior

The workflow automatically generates tags based on the Git event:

#### Default Tags

| Event | Tag Format | Example |
|-------|------------|---------|
| Push to branch | `<branch>` | `main`, `feat-my-feature` |
| Push tag | `<tag>` | `v1.0.0` |
| Pull request | `pr-<number>` | `pr-123` |

#### Optional Tags

| Input | Event | Tag Format | Example |
|-------|-------|------------|---------|
| `tag_branch_on_pr: true` | PR | `<branch>` | `feat-my-feature` |
| `tag_sha: true` | Any | `<sha>` | `abc123def456...` |
| `tag_branch_sha: true` | Push | `<branch>-<sha>` | `main-abc123def456...` |
| `tag_branch_sha: true` | PR | `<branch>-<sha>` | `feat-my-feature-abc123def456...` |

Pull requests also automatically get a `pr-<number>-<sha>` tag (e.g., `pr-123-abc123def456...`).

### Dockerfile Configuration

The `dockerfiles` input accepts a JSON array of objects with the following properties:

| Property | Description | Required | Default |
|----------|-------------|----------|---------|
| `dockerfile` | Path to the Dockerfile | Yes | - |
| `context` | Build context path | No | `.` |
| `prefix` | Prefix for the image name | No | `""` |
| `postfix` | Postfix for the image name | No | `""` |

The resulting image name will be: `<registry>/<owner>/<prefix><reponame><postfix>:<tag>`

### Examples

#### Basic Usage

Build and push a Docker image using the default Dockerfile:

```yaml
jobs:
  publish:
    uses: unbounded-tech/workflows-containers/.github/workflows/publish.yaml@main
```

#### Multiple Dockerfiles

Build and push multiple Docker images from different Dockerfiles:

```yaml
jobs:
  publish:
    uses: unbounded-tech/workflows-containers/.github/workflows/publish.yaml@main
    with:
      dockerfiles: |
        [
          {"dockerfile":"./Dockerfile","context":"."},
          {"dockerfile":"./api/Dockerfile","context":"./api","prefix":"api-"},
          {"dockerfile":"./worker/Dockerfile","context":"./worker","postfix":"-worker"}
        ]
```

#### PR Preview Images with Branch Tags

Build and push images on PRs with branch name tags for easy testing:

```yaml
name: PR Build

on:
  pull_request:
    branches: [main]

jobs:
  publish:
    uses: unbounded-tech/workflows-containers/.github/workflows/publish.yaml@main
    with:
      push: true
      tag_branch_on_pr: true
```

This creates tags like:
- `pr-123`
- `pr-123-abc123def456...`
- `feat-my-feature` (from `tag_branch_on_pr`)

#### Immutable SHA Tags

Tag every build with the commit SHA for immutable references:

```yaml
jobs:
  publish:
    uses: unbounded-tech/workflows-containers/.github/workflows/publish.yaml@main
    with:
      tag_sha: true
      tag_branch_sha: true
```

This creates tags like:
- `main` (branch name)
- `abc123def456...` (SHA only, from `tag_sha`)
- `main-abc123def456...` (branch + SHA, from `tag_branch_sha`)

#### Custom Registry (Docker Hub)

Push to Docker Hub instead of GitHub Container Registry:

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

#### Build Only (No Push)

Build the image without pushing (useful for validation):

```yaml
jobs:
  publish:
    uses: unbounded-tech/workflows-containers/.github/workflows/publish.yaml@main
    with:
      push: false
```

### PR Comments

When images are pushed during a pull request, the workflow automatically posts a comment with details about the published images, including all generated tags and links to the packages.

### How It Works

The workflow consists of three jobs:

1. **setup**: Processes the `dockerfiles` input and sets default values
2. **publish-container**: Builds and pushes Docker images (runs in parallel for each dockerfile)
3. **pr-comment**: Posts a comment on PRs with published image details

For each Dockerfile configuration, the workflow:

1. Checks out the repository
2. Sets up QEMU for multi-platform builds
3. Sets up Docker Buildx
4. Logs in to the container registry
5. Extracts metadata (tags, labels) using docker/metadata-action
6. Builds and optionally pushes the Docker image with registry caching

### Permissions

The calling workflow requires the following permissions:

```yaml
permissions:
  packages: write      # For pushing to GitHub Container Registry
  contents: read       # For accessing repository contents
  pull-requests: write # For posting PR comments
```
