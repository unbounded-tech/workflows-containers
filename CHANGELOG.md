### What's changed in v1.7.0

* feat(publish): add platforms input for multi-arch builds (#27) (by @patrickleet)

  Adds an optional `platforms` input to publish.yaml that is passed through
  to docker/build-push-action's `platforms:` parameter. Default is empty
  (native-only) so existing consumers are unaffected.

  QEMU is already set up unconditionally by the workflow, so no other
  changes are needed — passing `linux/amd64,linux/arm64` Just Works and
  produces a manifest list at the published tag(s).

  Motivating use case: an image that needs to run on arm64 EKS nodes
  (authstack-reconciler) was being published amd64-only and failed to
  pull on the cluster.


See full diff: [v1.6.0...v1.7.0](https://github.com/unbounded-tech/workflows-containers/compare/v1.6.0...v1.7.0)
