# WordPress incident triage evaluation

Model: qwen2.5:1.5b-instruct

| Case | Expected cause | Ranked causes | Expected cause rank | First check | Expected first check | Request time |
| --- | --- | --- | ---: | --- | --- | ---: |
| gateway-dimension | alert-wrong-backend | alert-wrong-backend, backend-unhealthy, image-pull-failed | 1 | gateway-routing | alert-dimension | 1.22 s |
| key-vault-mount | csi-mount-overlap | alert-wrong-backend, csi-mount-overlap, backend-unhealthy | 2 | alert-dimension | pod-events | 1.81 s |
| interrupted-plan | terraform-state-lock | terraform-state-lock, alert-wrong-backend, backend-unhealthy | 1 | terraform-process | terraform-process | 1.63 s |
| monitor-registration | monitor-provider-unregistered | monitor-provider-unregistered, backend-unhealthy, image-pull-failed | 1 | insights-provider | insights-provider | 1.67 s |
| vmss-extension-tag | vmss-extension-tag-too-long | vmss-extension-tag-too-long, backend-unhealthy, image-pull-failed | 1 | vmss-force-tag | vmss-force-tag | 1.70 s |

- Correct cause ranked first: 4/5
- Correct cause in the top three: 5/5
- Expected first check selected: 3/5
- Invalid model responses: 0/5
- Median request time for valid responses: 1.67 s

The cases are reconstructed from resolved lab incidents. This small, closed-catalog test measures agreement with the expected answers. Request time includes local model startup where applicable. It omits the time required for human review and diagnosis.
