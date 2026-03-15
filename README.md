# Automated Azure Linux Environment via Terraform

---

## Architecture Diagram

[![View Diagram](https://excalidraw.com/)](https://excalidraw.com/)  
*Click the link above to view or edit the architecture diagram on Excalidraw*

Conceptual diagram:
```
┌──────────────┐     ┌───────────────────────────────┐     ┌──────────────┐
│  Developer   │──▶──│  GitHub Actions (CI/CD)      │──▶──│  Azure Cloud │
└──────────────┘     └────────────┬─────────────────┘     └─────┬────────┘
                                  │                               │
                                  ▼                               ▼
                           ┌─────────────┐               ┌─────────────────┐
                           │ Terraform   │    ┌─────────▶│ Resource Group  │
                           └──────┬──────┘    │          └──────┬──────────┘
                                  │           │                 │
                                  ▼           │                 ▼
                        ┌─────────────────┐   │      ┌──────────────────────┐
                        │ Virtual Network │───┘      │ Network Security     │
                        └──────┬──────────┘          │ Group (NSG - SSH ⬤) │
                               │                     └─────────┬────────────┘
                               ▼                               ▼
                        ┌───────────────┐       ┌─────────────────────────┐
                        │ Subnet        │◀──────│ Public IP (Static)      │
                        └─────┬─────────┘       └─────────────┬───────────┘
                              │                               ▲
                              ▼                               │
                       ┌─────────────┐               ┌────────┴───────────┐
                       │ Network     │──────────────▶│ Linux VM (Ubuntu)  │
                       │ Interface   │ (ENI)         │  -- B-series Burst │
                       └─────────────┘               └────────────────────┘
```
---

## Technical Stack

- **Terraform**: Infrastructure provisioning
- **Azure**: Cloud service provider (ARM resources)
- **Linux (Ubuntu 22.04 LTS)**: Virtual machine OS
- **GitHub Actions**: CI/CD (automate IaC deployments)

---

## Key Features

- **Infrastructure as Code (IaC):**  
  Full environment described in Terraform configuration for 100% repeatability and easy versioning.

- **Fast Provisioning:**  
  Automated deployment of Azure resources including VNet, Subnet, NSG, Linux VM, and Public IP.

- **CI/CD Ready:**  
  Designed for integration with GitHub Actions for automated builds and deployments.

---

## Security Hardened

- **Restricted Inbound Traffic:**  
  Azure Network Security Group (NSG) allows only SSH (port 22) inbound.  
  *(Tip: In production, replace `*` source with your office/home IP for better access control.)*

---

## Cost-Optimized

- **Burstable VM (B-series):**  
  Uses cost-efficient burstable (B2ats_v2) Azure VM SKU for demo/dev workloads.

---

## Usage

1. **Clone the repo**
    ```
    git clone https://github.com/yourusername/azure-terraform-linux.git
    cd azure-terraform-linux
    ```

2. **Initialize Terraform**
    ```
    cd terraform
    terraform init
    ```

3. **Plan and Apply**
    ```
    terraform plan
    terraform apply
    ```

4. **Get Public IP**
    - After apply completes, Terraform will output the public IP address of your VM.

---

## Notes & Recommendations

- **Change default credentials!** The demo config uses hardcoded admin and password for illustration only.
- **Secure your NSG** further before putting into production.
- **Clean up resources** to avoid unnecessary Azure costs:
    ```
    terraform destroy
    ```

---

## License

This project is licensed under the [MPL 2.0 License](terraform/.terraform/providers/registry.terraform.io/hashicorp/azurerm/3.117.1/darwin_arm64/LICENSE.txt).

---
