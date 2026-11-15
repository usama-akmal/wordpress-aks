# WordPress Modernization on Azure AKS


This project migrates WordPress from an Azure VM Scale Set to AKS while
keeping the same Application Gateway URL and private MySQL database.
GitHub Actions builds and scans the image, publishes it to Azure Container
Registry, and deploys the published digest with Helm.

## What the project demonstrated

- Two WordPress replicas on one AKS node can serve the same uploaded files
  using a shared Azure Files volume.
- WordPress retrieves database credentials from Key Vault using Microsoft
  Entra Workload ID and Secrets Store CSI.
- The running image digest matched the GitHub Actions release output.
  A Helm rollback was also tested.
- Both environments returned 30 successful responses from 30 sequential
  requests. Median latency was 1.14 s on the VMSS baseline and 3.58 s on
  AKS. The test measured response time and did not establish the cause
  of the difference.

## Project documentation

- [Architecture diagram](docs/architecture.md)
- [Architecture decisions](docs/architecture-decisions.md)
- [Operator runbook](docs/operator-runbook.md)
- [Advisory AI PR reviewer](docs/ai/pr-reviewer.md)
