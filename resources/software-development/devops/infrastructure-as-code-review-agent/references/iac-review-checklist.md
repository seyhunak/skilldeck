# IaC Review Checklist

Use alongside the operating procedure. Items are common review points, not an exhaustive standard; confirm provider-specific behaviour in the provider's documentation for the version in use.

## Plan reading (Terraform / OpenTofu)

- Symbols: `+` create, `~` update in place, `-/+` destroy then create, `+/-` create then destroy, `-` destroy, `<=` data source read.
- "forces replacement" annotations identify the attribute causing a replace.
- `(known after apply)` on identifiers that other resources depend on can cascade replacements.
- In JSON plans, `resource_changes[].change.actions` lists actions; `replace_paths` shows the triggering attributes.
- Changes to `count` index or `for_each` keys change resource addresses; use `moved` blocks.

## CloudFormation

- Change set `Replacement: True | Conditional` marks replacements.
- Stateful resources should have `DeletionPolicy: Retain` or `Snapshot` and `UpdateReplacePolicy` set deliberately.
- Stack policies can prevent updates to critical resources.

## Kubernetes

- `kubectl diff` or rendered output before and after; immutable fields (for example a Deployment's `spec.selector`) cannot be changed in place.
- CRD changes and cluster-scoped objects affect every namespace.
- `helm upgrade` with changed resource names deletes the old objects.

## Security checks

| Area | Look for |
|---|---|
| Network | Ingress `0.0.0.0/0` or `::/0` on SSH, RDP, database ports; public subnets for data stores; public load balancers that should be internal |
| Storage | Public access block disabled; public ACLs or policies; unencrypted volumes, snapshots, buckets |
| Identity | `Action: "*"` or `Resource: "*"`; `iam:PassRole` broadly granted; trust policies allowing any principal; static access keys |
| Secrets | Literal secrets in variables, user data, environment blocks, ConfigMaps; secrets exposed via outputs |
| Logging | Audit logs, flow logs, or access logging disabled or retention set very short |
| Kubernetes pods | `privileged: true`, `hostNetwork`, `hostPID`, `hostPath`, `runAsUser: 0`, `allowPrivilegeEscalation` not false, capabilities not dropped, `automountServiceAccountToken` where not needed |
| Kubernetes RBAC | `cluster-admin` bindings, wildcard verbs or resources, bindings to default service accounts |

## Reliability checks

- Multi-AZ for production data stores and node groups.
- Backups, point-in-time recovery, and deletion protection on stateful resources.
- Requests/limits, probes, PodDisruptionBudgets, topology spread or anti-affinity for replicated workloads.
- Rolling update `maxUnavailable` not allowing full outage.
- Image references pinned by version or digest.

## State and structure

- Remote backend with locking and encryption; state access restricted.
- `required_providers` and module versions constrained.
- No resource managed by two stacks or by IaC plus manual changes.
- Environments differ by variables or overlays, not duplicated code.

## Cost drivers to call out

- Instance or node size and count; managed database class; provisioned throughput or IOPS.
- NAT gateways and cross-AZ or internet egress paths.
- Log and metric retention, high-cardinality metrics.
- Non-production resources without schedules or auto-shutdown.
