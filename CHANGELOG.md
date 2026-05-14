# Changelog

All notable changes to the Reel Helm chart are documented here. CLI changes live in [`getreeldev/reel-cli`](https://github.com/getreeldev/reel-cli/blob/main/CHANGELOG.md); GitHub Action changes live in [`getreeldev/reel-action`](https://github.com/getreeldev/reel-action/blob/main/CHANGELOG.md).

The chart version tracks the reel CLI / agent image version (`vX.Y.Z` chart ⇄ `getreel/agent:vX.Y.Z`).

## v1.7.0

- **Image-tag pins bumped to v1.7.0** for `getreel/agent`, `getreel/init-criu`, `getreel/init-trivy`. The agent and init-criu images carry the v1.7.0 CRIU detection overhaul — see the [CLI changelog](https://github.com/getreeldev/reel-cli/blob/main/CHANGELOG.md) for full details.

### Chart-side changes

- **Auto-create install namespace** (`templates/namespace.yaml`). New template gated on `namespace.create` (default `true`). `helm install reel oci://docker.io/getreel/helm -n reel` on a fresh cluster no longer requires `--create-namespace`. Helm fully owns the namespace lifecycle when it creates it: deleted on uninstall. Reel itself is stateless (config from K8s annotations, evidence in S3 or hostPath dirs outside the namespace) so deleting the namespace on uninstall loses nothing user-meaningful. A `lookup` guard skips the template when the namespace already exists, so pre-creating the namespace by mistake doesn't break the install — helm just won't own that pre-existing namespace's lifecycle. Set `--set namespace.create=false` to disable the template entirely (e.g., when a cluster admin manages the namespace).

- **Pod-shared `reel-init-state` emptyDir** (`templates/daemonset.yaml`). New emptyDir volume mounted rw in the init-criu container at `/reel-init` and ro in the agent container at the same path. init-criu writes a status marker (`source=reel|host|none`) that the agent reads to determine CRIU availability — no host filesystem access required from the agent container. Gated on `initCriu.enabled`: when disabled, no volume, no mount, no image pull.

- **`CRIU_ENABLED` env var removed from the agent's pod spec** (`templates/daemonset.yaml`). The agent no longer trusts this env var as a stand-in for CRIU presence; the marker file is the authoritative signal. Existing installs upgrading from v1.6.x will see the env var disappear from the agent container's environment.

### Migration

- Existing `helm upgrade --version 1.7.0` users will see a brief rolling restart of agent pods to pick up the new manifest. No values changes required for default behavior.
- Users who customized via `initCriu.enabled=false` will see `Checkpoint: ✓ (init-criu disabled in chart; CRIU presence not verified, checkpoint is best-effort)` in `reel status` instead of the previous `✗ Checkpoint`. Checkpoint commands now attempt and surface real runtime errors if no CRIU is on the host's PATH.
- Cleaning up reel's CRIU from a node: see the [CLI changelog](https://github.com/getreeldev/reel-cli/blob/main/CHANGELOG.md) for the `/uninstall.sh` invocation.

## v1.6.0

- **Image-tag pins bumped to v1.6.0** for `getreel/agent`, `getreel/init-criu`, `getreel/init-trivy`. Picks up a CLI / agent release that adds (a) **VEX annotation in the scheduler** — `reel.io/schedule: "*/5 * * * * | upload sbom --scanners vuln,vex --s3-bucket evidence"` now ships vex-hub-annotated CycloneDX SBOMs to S3; (b) actionable runtime-detection errors and a `--socket` flag for non-default runtime socket paths; and (c) the **scheduler verb split** — `export` is local-only, `upload` is for S3. See the [CLI changelog](https://github.com/getreeldev/reel-cli/blob/main/CHANGELOG.md) for migration details if any of your pods have `reel.io/schedule` annotations using `export X --s3-bucket Y`.
- **Namespace auto-create** (in-place chart patch, 2026-05-13). Adds `templates/namespace.yaml` so `helm install reel oci://docker.io/getreel/helm -n reel` works on a fresh cluster without `--create-namespace`. Gated on `namespace.create` (default `true`); set to `false` if a cluster admin pre-creates the namespace. The Namespace resource carries `helm.sh/resource-policy: keep` so `helm uninstall` doesn't delete it (which would take all forensic artifacts with it). Existing installs are unaffected — the existing namespace already has `helm uninstall` semantics from outside the chart.

## v1.5.3

- **Image-tag pins bumped to v1.5.3** for `getreel/agent`, `getreel/init-criu`, `getreel/init-trivy`. See the [CLI changelog](https://github.com/getreeldev/reel-cli/blob/main/CHANGELOG.md) for what's in the corresponding agent release — in short, a release-pipeline fix so that `reel version` from inside the agent pod reports the chart's `appVersion` (e.g. `v1.5.3`) instead of the underlying RC suffix. No chart-side template changes.

## v1.5.2

- **Image-tag pins bumped to v1.5.2** for `getreel/agent`, `getreel/init-criu`, `getreel/init-trivy`. See the [CLI changelog](https://github.com/getreeldev/reel-cli/blob/main/CHANGELOG.md) for what's in the corresponding agent release. No chart-side template changes — purely an agent version bump.

## v1.5.1

- **Image-tag pins bumped to v1.5.1** for `getreel/agent`, `getreel/init-criu`, `getreel/init-trivy`. See the [CLI changelog](https://github.com/getreeldev/reel-cli/blob/main/CHANGELOG.md) for what's in the corresponding agent release.
- **Trivy binary now reaches the agent via the shared volume.** Renamed the `security-bins` volume to `trivy-bin` and mounted it at `/opt/trivy/bin` in both init-trivy and the agent container; updated the agent's `PATH` / `LD_LIBRARY_PATH` accordingly. Previously the shared volume was mounted at `/opt/security-tools/bin` while init-trivy wrote the binary to `/opt/trivy/bin` (the agent's expected location) — into its own filesystem layer, not the shared volume. The shared volume stayed empty and the agent re-downloaded Trivy on every cold start via its toolcache fallback.
- **ClamAV virus DB persists across pod restarts.** Added a `clamav-db` hostPath volume at `/var/tmp/reel/clamav` mounted at `/var/lib/clamav` in the clamd sidecar, plus an `init-clamav` busybox init container that `chmod 777`s the directory so clamd's runtime user can write to it. Without this, freshclam re-downloaded the full ClamAV DB (~110 MB) on every pod restart.

## v1.5.0

- **Image-tag pins bumped to v1.5.0** for `getreel/agent`, `getreel/init-criu`, `getreel/init-trivy`. Picks up the CLI / agent VEX-support release (new `--scanners vex` flag on `reel export sbom`). No chart-side template changes — the agent simply gains the new CLI subcommand.

## v1.4.0

- **Image-tag pins bumped to v1.4.0** for `getreel/agent`, `getreel/init-criu`, `getreel/init-trivy` (catching up three minors of drift; the chart had been pinned to v1.0.1 while the agent images shipped through v1.4.0).
- **init-criu** at v1.4.0 carries CRIU v4.2 + the four MPTCP commits from the rebased `andreazorzetto/criu@mptcp-upstream` branch — required to checkpoint Go 1.24+ services.
- **init-trivy** at v1.4.0 carries Trivy 0.70.0.
- **clamav image stays floating at `1.5`** (existing convention; resolves to the latest 1.5.x at pull time).
- **RC override pattern documented**: the release-rc.yml workflow in `andreazorzetto/reel` overrides `initCriu` / `initTrivy` image tags via `HELM_EXTRA_ARGS` during the agent-tests job so RC validation targets the just-built `:vX.Y.Z-rc.N` images, while end-user installs of the published chart at GA get the matching `:vX.Y.Z` images.

## v1.3.0 and earlier

Chart releases v1.0.0 through v1.3.0 tracked the corresponding reel agent image versions. Earlier history in the v0.6.x line predates the chart-version rename and is preserved in the git log.
