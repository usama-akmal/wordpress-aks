# VM Baseline Verification

## Architecture
Browser -> Application Gateway -> WordPress VM Scale Set -> private MySQL

## Configuration
- Region: westus2
- Resource group: rg-final-project
- Scale set: vmss-wordpress
- VM size: Standard_B2als_v2
- Instance count: 1
- OS: Ubuntu 24.04 LTS
- Web server: Apache
- PHP: 8.3
- WordPress: 7.1.4
- Database: MySQL Flexible Server 8.4
- Database size: B_Standard_B1ms
- Upload storage: local VM disk
- Database credentials: Key Vault via managed identity

## Verification
- Website URL: http://wp-36536035c2eb.westus2.cloudapp.azure.com/
- Published test-post URL: http://wp-36536035c2eb.westus2.cloudapp.azure.com/?p=6
- Sample image displays: yes
- Dashboard login works: yes
- Homepage HTTP status: 200
- Verification date: 14/11/2026

## Current limitations
- One application instance; no application redundancy.
- Uploads reside on the VM and require migration.
- Gateway web access is restricted to the configured client IP.
- Current gateway listener uses HTTP.
