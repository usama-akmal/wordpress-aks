# WordPress operator runbook

The WordPress Helm release and namespace are both `wordpress`. The AKS cluster is `aks-k8s-lab` in `rg-k8s-lab`. Application Gateway and MySQL are in `rg-final-project`.

## Deploy a change to the existing environment

This workflow needs the provisioned AKS cluster, the `wordpress` Helm release, and the project's ACR registry. Before the first run in a repository, configure the GitHub Actions variables `ACR_LOGIN_SERVER`, `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, and `AZURE_SUBSCRIPTION_ID`. Confirm that the Azure identity has a federated credential for the repository's `main` branch and permission to publish to ACR and deploy the release in AKS.

1. Create a feature branch from the latest `main`. Commit the change and push the branch.
2. Open a pull request, review the diff, and wait for the PR validation checks to pass. Merge through GitHub.
3. Open **Actions → Publish and deploy WordPress** and select the run for that merge. The workflow builds and scans the image, publishes it to ACR, and upgrades the Helm release with the published digest.
4. In the run summary, verify that **Published image** and **Deployed image** match. Run the release checks below and confirm that the expected change is visible.

## Verify a release

Use the Azure CLI-authenticated Kubernetes context for `aks-k8s-lab`. Check the context before running any cluster command.

```sh
kubectl config current-context
```

Run these checks from a client allowed by the Application Gateway NSG.

```sh
kubectl -n wordpress rollout status deployment/wordpress --timeout=120s
kubectl -n wordpress get deployment wordpress
kubectl -n wordpress get pvc wordpress-uploads
kubectl -n wordpress get deployment wordpress \
  -o jsonpath='{.spec.template.spec.containers[?(@.name=="wordpress")].image}{"\n"}'
curl --fail --silent --show-error --location --max-time 20 \
  --output /dev/null --write-out 'HTTP %{http_code}\n' \
  'http://wp-36536035c2eb.westus2.cloudapp.azure.com/'
```

Expect two ready replicas, a `Bound` uploads claim, the exact `@sha256:` image reference in the GitHub Actions release output, and a final HTTP 2xx response.

## Interpret alerts

- **Application Gateway backend health.** `wordpress-aks-backend-unavailable` fires when the average `HealthyHostCount` for `wordpress-aks-pool~wordpress-aks-http` falls below the configured threshold over five minutes. Check gateway backend health first, then follow the outage steps below. A firing alert describes what the gateway sees and does not identify the failing component by itself.
- **Azure budget.** A budget email reports that actual costs reached a configured spending threshold. Confirm the scope and threshold in the email, check Cost Analysis for the resource driving the change, and use the teardown steps for resources the project no longer needs. See [Azure cost evidence](azure-costs.md) for the budget configuration.

## Investigate an outage or failed deployment

1. Check the latest GitHub Actions run. Find the first failing step in the build, scan, publish, or Helm deployment sequence.
2. If the public URL fails, check Azure Monitor and Application Gateway backend health. The `wordpress-aks-backend-unavailable` alert uses `HealthyHostCount` for `wordpress-aks-pool~wordpress-aks-http`.
3. Check Kubernetes events. For an image-pull failure, verify the deployed digest and ACR pull access. For a CSI mount failure, check the WordPress service account, workload identity federation, and Key Vault access. For a database readiness failure, check private DNS, VNet peering, and TCP connectivity to MySQL on port 3306.

```sh
az network application-gateway show-backend-health \
  --resource-group rg-final-project --name agw-wordpress
kubectl -n wordpress get pods -o wide
kubectl -n wordpress get events --sort-by=.metadata.creationTimestamp
```

## Roll back an application release

```sh
helm history wordpress --namespace wordpress
```

Choose the last revision backed by a successful release check. Replace the placeholder with that revision number and run:

```sh
helm rollback wordpress LAST_KNOWN_GOOD_REVISION --namespace wordpress
kubectl -n wordpress rollout status deployment/wordpress --timeout=120s
helm history wordpress --namespace wordpress
```

Repeat the release verification above and confirm that the image digest matches the selected revision. Helm creates a new revision for the rollback. A Helm rollback restores the Kubernetes release configuration. Database contents and uploaded files require their own recovery procedures. Revert the breaking change through a PR before the next deployment so the repository reflects the intended release.

## Tear down after the final demo

1. Save the evidence for submission and export any database or upload data you need to keep. Check that you have a restorable copy before deleting resources. Wait for deployment workflows to finish.
2. With the correct AKS context selected, inventory the project releases and storage with `helm list --namespace wordpress` and `kubectl -n wordpress get pvc`. Uninstall the project Helm releases and remove project-only Kubernetes resources. Check each PVC's backing volume and reclaim policy before deleting a claim. Keep the pre-existing AKS cluster and any other workloads on it.
3. From the `infra` directory, restore the required Terraform inputs using the existing runtime setup. Run `terraform state list` and `terraform plan -destroy -input=false`. Review the planned deletions, including dependencies on the reused AKS cluster. When the plan matches the project inventory, run `terraform destroy -input=false` and review the confirmation plan before accepting it.
4. Check Azure for project resources created outside Terraform. Use `az resource list --resource-group rg-final-project --output table` and check the reused AKS cluster for any remaining project releases, storage, or permissions.
5. Keep the Terraform backend available until the infrastructure state has no managed resources left. Before removing bootstrap storage in a separate operation, verify that its container is dedicated to the lab and that neither Terraform configuration still uses it as an active backend.
