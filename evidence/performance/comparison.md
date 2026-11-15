# WordPress performance before and after migration

The VMSS baseline (November 14, 2026 UTC) and AKS run (November 15, 2026 UTC) used the same Application Gateway URL and macOS client platform. Each run used three warmups, 30 sequential measured requests, a 0.2-second pause between samples, and a 10-second socket timeout. Timings include redirects and the full HTML response body for successful requests.

| Metric | VMSS baseline | AKS after cutover | Change |
| --- | ---: | ---: | ---: |
| Mean latency | 1.152 s | 3.626 s | +2.474 s (3.15×) |
| Median latency | 1.144 s | 3.579 s | +2.435 s (3.13×) |
| p95 latency | 1.326 s | 4.271 s | +2.946 s (3.22×) |
| Successful requests | 30/30 | 30/30 | 0 requests |
| Error rate | 0% | 0% | 0 percentage points |

The AKS run had higher latency across the measured percentiles, while both runs completed all requests successfully. The VMSS and its MySQL database were in West US 2. After cutover, Application Gateway and MySQL remained in West US 2, and the application ran on AKS in East US 2. The new cross-region request and database paths are possible contributors. This test measured end-to-end responses without timing the individual hops.

The AKS deployment ran two WordPress replicas that shared an Azure Files upload volume. The shared-volume test wrote a file through one replica and read it through the other. This verified shared media access independently of the latency measurements.

The samples were collected on different days. Public-network latency and cache state may have differed. The test covers sequential HTML requests. It leaves asset loading, browser rendering, peak throughput, and long-term availability unmeasured.
