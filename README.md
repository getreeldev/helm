<p align="center">
  <img src="./docs/logo-light.svg#gh-light-mode-only" alt="Reel Logo" width="80" height="80">
  <img src="./docs/logo.svg#gh-dark-mode-only" alt="Reel Logo" width="80" height="80">
</p>

<h1 align="center">Reel Helm Chart</h1>

<p align="center">
  <strong>Continuous Compliance</strong> for Kubernetes containers.
  <br>
  <a href="https://getreel.dev/docs">Documentation</a> ·
  <a href="https://getreel.dev">Website</a>
</p>

---

## Contents

- [What is Reel?](#what-is-reel)
- [Quick Start](#quick-start)
- [Requirements](#requirements)
- [Configuration](#configuration)

---

## What is Reel?

Reel captures container state before it disappears. When a pod crashes, scales down, or gets terminated, the evidence is gone. Reel preserves it.

- **Filesystem Layers** — Diff-based snapshots of container changes
- **Security Scanning** — SBOM, CBOM, vulnerability and malware detection
- **Forensics** — Memory, processes, network connections
- **Checkpoint** — Full process state capture using CRIU
- **Scheduling** — Annotation-driven automated captures

---

## Quick Start

```bash
helm install reel oci://docker.io/getreel/helm -n reel --create-namespace
```

Runs a short **3-hour grace period** without a license. [Request a free 30-day trial license](https://getreel.dev) for full evaluation, or a production license.

---

## Requirements

| Component | Version |
|-----------|---------|
| Kubernetes | 1.25+ |
| containerd | 2.0+ |
| Helm | 3.x |

Node architectures: `linux/amd64` and `linux/arm64` — the agent and init images ship as multi-arch manifests, so Kubernetes pulls the right one per node (including mixed-arch clusters).

See [Requirements](https://getreel.dev/docs/requirements) for cloud provider notes and full details.

---

## Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `license.token` | License token | `""` |
| `license.secretRef.name` | Secret name for license | `""` |
| `license.secretRef.key` | Key in secret | `token` |
| `config.clusterName` | Cluster identifier for S3 paths | `""` |
| `config.logLevel` | debug, info, warn, error | `info` |
| `config.logFormat` | json, console | `console` |
| `initCriu.enabled` | Install CRIU for checkpointing | `true` |
| `initTrivy.enabled` | Pre-load Trivy vulnerability database | `true` |
| `clamav.enabled` | ClamAV sidecar for malware scanning | `true` |
| `scheduler.enabled` | Annotation-driven scheduled captures | `true` |
| `imageCredentials.create` | Create registry secret (for private registries) | — |
| `imageCredentials.secretName` | Name of registry secret | — |

See [S3 Exports](https://getreel.dev/docs/s3-exports) for S3 configuration.

---

## Uninstall

```bash
helm uninstall reel -n reel
```

---

## Documentation

[getreel.dev/docs](https://getreel.dev/docs)
