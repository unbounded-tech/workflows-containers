### What's changed in v1.4.0

* chore(deps): update unbounded-tech/workflow-vnext-tag action to v1.20.2 (#16) (by @renovate[bot])

  Co-authored-by: renovate[bot] <29139614+renovate[bot]@users.noreply.github.com>

* feat: Add branch reference type to Docker metadata action (#17) (by @patrickleet)

  * **Features**
    * Add branch event reference type to Docker metadata action
    * Add `tag_branch_on_pr` to optionally also create branch tags for PRs

  * **Chores**
    * Added an additional Docker image tag type to the build workflow.
    * Switched workflow references from an external source to local workflow files for CI orchestration.


See full diff: [v1.3.0...v1.4.0](https://github.com/unbounded-tech/workflows-containers/compare/v1.3.0...v1.4.0)
