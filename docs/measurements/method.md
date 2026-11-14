# HTTP Measurement Method

- Client: my local machine
- Endpoint: public WordPress homepage through Application Gateway
- Warmup requests: 3
- Measured requests: 30
- Concurrency: 1
- Pause between requests: 0.2 seconds
- Compression requested: identity
- Redirects: followed
- Latency: complete HTML response for successful requests
- Failures: reported separately

Repeat after AKS migration using the same script, client,
network, request settings, and equivalent WordPress content.

This is a small response-time sample. It does not establish
maximum throughput, concurrent capacity, or long-term availability.
