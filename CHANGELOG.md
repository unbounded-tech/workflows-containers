### What's changed in v1.5.0

* feat: optional sha tag (#18) (by @patrickleet)

  ##### Summary

  Added support for optionally tagging Docker images with commit SHA in the reusable publish workflow.

  ##### Changes

  - **New workflow input**: Added `tag_sha` boolean parameter to `.github/workflows/publish.yaml` (default: `false`)
  - **SHA-based tagging**: When `tag_sha` is enabled, images are automatically tagged with the commit SHA (`type=raw,value={github.sha}`)
  - **Example workflow**: Added `.github/workflows/on-push-branch.yaml` demonstrating usage of the new `tag_sha` feature

  ##### Benefits

  - Enables precise image versioning by commit SHA
  - Maintains backward compatibility (opt-in feature)
  - Facilitates debugging and rollback scenarios by providing immutable SHA-based tags

  ##### Usage

  ```yaml
  uses: ./.github/workflows/publish.yaml
  with:
    tag_sha: true


See full diff: [v1.4.0...v1.5.0](https://github.com/unbounded-tech/workflows-containers/compare/v1.4.0...v1.5.0)
