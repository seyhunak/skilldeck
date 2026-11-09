# Maintainer review policy

CI passing is necessary but not sufficient for publication.

Review each submission for:

1. **Usefulness:** Does it solve a clear task with enough detail to be usable?
2. **Completeness:** Are inputs, outputs, workflow, examples, limitations, and validation clear?
3. **Originality:** Is it meaningfully distinct from existing resources?
4. **Accuracy:** Are technical claims and compatibility levels supported?
5. **Safety:** Does it request secrets, destructive actions, unsafe execution, or inappropriate data access?
6. **Licensing:** Is the author entitled to distribute every included component under the declared license?
7. **Maintainability:** Are dependencies, version, and platform assumptions documented?

A contributor's `status` must stay `submitted` in a pull request. Maintainers set it to `approved` when merging, and only approved resources are published in the generated catalog.

Do not merge merely to meet a resource-count target. Reject duplicates, thin wrappers around generic prompts, misleading compatibility claims, and incomplete packages.
