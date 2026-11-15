# WordPress on Azure

```mermaid
flowchart LR
    Client["Browser"] --> Gateway["Azure Application Gateway"]

    subgraph West["West US 2"]
        Gateway
        VMSS["WordPress VM Scale Set"]
        MySQL["Private Azure Database for MySQL"]
        Vault["Azure Key Vault"]
    end

    subgraph East["East US 2"]
        Traefik["Traefik internal load balancer"]
        WP["WordPress on AKS · 2 replicas"]
        Uploads["Azure Files · shared uploads"]
        Traefik --> WP
        WP --> Uploads
    end

    Gateway -. "Original route" .-> VMSS
    Gateway -->|"Current route over VNet peering"| Traefik
    VMSS -. "Original database connection" .-> MySQL
    WP -->|"Private MySQL over VNet peering"| MySQL
    WP -->|"Workload Identity and Secrets Store CSI"| Vault

    Actions["GitHub Actions"] -->|"Build, scan, publish"| ACR["Azure Container Registry"]
    Actions -->|"Helm deploys the same image digest"| WP
    ACR -->|"AKS pulls by digest"| WP
    Gateway -->|"HealthyHostCount"| Monitor["Azure Monitor alert and email action group"]
```

The migration kept the public Application Gateway URL and the private MySQL
database. Application Gateway now sends traffic to Traefik in AKS. Both
WordPress replicas mount the same Azure Files share for uploads.

The AKS cluster runs in East US 2 because the West US 2 regional vCPU
quota was already in use during provisioning. The two regions communicate
through VNet peering. Both WordPress replicas run on one AKS node, so the
lab demonstrates pod replication and shared storage without node-level
redundancy.