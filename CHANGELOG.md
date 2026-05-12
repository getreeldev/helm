# Changelog

All notable changes to the Reel Helm chart are documented here. CLI changes live in [`getreeldev/reel-cli`](https://github.com/getreeldev/reel-cli/blob/main/CHANGELOG.md); GitHub Action changes live in [`getreeldev/reel-action`](https://github.com/getreeldev/reel-action/blob/main/CHANGELOG.md).

The chart version tracks the reel CLI / agent image version (`vX.Y.Z` chart ⇄ `getreel/agent:vX.Y.Z`).

## v1.5.1

- **Trivy binary now actually reaches the agent.** The agent expects `/opt/trivy/bin/trivy` (binary convention since Feb 2026) but the chart was mounting the shared volume at `/opt/security-tools/bin`. init-trivy was writing the binary to a path inside its own filesystem layer, the shared volume stayed empty, and the agent fell through to its toolcache fallback (downloads Trivy on every cold start). Renamed the `security-bins` volume to `trivy-bin`, mounted at `/opt/trivy/bin` in both init-trivy and agent containers, and updated the agent's `PATH` / `LD_LIBRARY_PATH` to match. Init-trivy is no longer dead weight.
- **ClamAV virus DB persists across pod restarts.** Added a `clamav-db` hostPath volume at `/var/tmp/reel/clamav` mounted at `/var/lib/clamav` in the clamd sidecar, plus an `init-clamav` busybox init container that `chmod 777`s the directory so clamd's runtime user can write to it. Aligns with the agent binary's `/var/tmp/reel/clamav` convention. Without this, freshclam re-downloaded the full ClamAV DB (~110 MB) on every pod restart.
- **Image-tag pins bumped to v1.5.1** for `getreel/agent`, `getreel/init-criu`, `getreel/init-trivy`. Picks up the corresponding CLI / agent release that routes binary-blob exporters (layer / memory / checkpoint / frame) through the shared S3-credential helper — fixes IMDS timeouts on non-EC2 clusters that configure `aws-credentials` via secret.

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
