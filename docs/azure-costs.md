# Azure cost evidence

## Exported usage

Azure Cost Analysis reported **USD 9.85** for the usage dates in the export, November 13–15, 2026. The total uses the unrounded amounts from the CSV. The export contains daily totals only and does not identify the selected scope, filters, resources, or resource groups.

| Usage date | Reported cost (USD) |
| --- | ---: |
| 2026-11-13 | 0.61 |
| 2026-11-14 | 5.55 |
| 2026-11-15 | 3.69 |
| **Total** | **9.85** |

## Budget evidence

The November 15 Azure portal capture shows `wordpress-project-budget`, an invoice-section budget with no filters. It resets monthly and has a **USD 100** limit. Actual-cost email alerts are set at **50%, 80%, and 100%**. The portal shows **USD 25.80** of evaluated spend at that budget scope. It lists November 1, 2026 as the creation date and November 21, 2026 as the expiration date.

The invoice-section budget is verified. A budget scoped to `rg-final-project` and a cost breakdown by resource group have yet to be verified.
