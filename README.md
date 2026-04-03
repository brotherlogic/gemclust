# gemclust

This is an **AI-Run Kubernetes Cluster** managed entirely through GitOps using [Flux](https://fluxcd.io).

## 🚀 Features

- **Automated GitOps via Flux:** The entire cluster state is synced, managed, and controlled declaratively via Flux controllers.
- **Structured Resource Separation:** Uses dedicated `my-cluster/infrastructure/` and `my-cluster/apps/` directories, loaded dynamically by independent Flux Kustomizations (`infrastructure.yaml`, `apps.yaml`).
- **Declarative Infrastructure & Dependencies:** A local Grafana instance operates via a `HelmRelease` resource inside `infrastructure/grafana/`. The cluster includes an automated node-untainting mechanism to safely allow workloads on single-node setups without needing per-app tolerations.
- **CI Manifest Validation Pipeline:** A GitHub Actions workflow (`.github/workflows/validate-cluster.yml`) automatically runs on every Pull Request. It dynamically builds Kustomize configs and strictly validates all manifests against official Kubernetes schemas using `kubeconform`.
- **Integrated Agent Workflows:** Provides a custom `.agent/workflows/finish-task.md` rule that allows an AI assistant to automatically encapsulate work and commit changes into standard GitHub feature branches.

## 📁 Usage

To install a new tool or custom container:
1. Create a folder in `my-cluster/apps/`.
2. Drop your standard Kubernetes manifests or Flux extensions inside.
3. Reference those files in `my-cluster/apps/kustomization.yaml`.

Once merged to `main`, Flux will instantly detect the changes and synchronize your new application into the cluster!
