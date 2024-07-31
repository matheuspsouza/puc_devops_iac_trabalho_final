# puc_devops_iac_trabalho_final

## Objetivo
Cria um pipeline de CI/CD que provisiona uma infraestrutura na Azure usando Terraform, configura os servidores usando Ansible, e utiliza GitHub Actions para orquestrar todo o processo.

Recursos a serem criados na Azure:
- Resource Group
- Virtual Network (VNet)
- Subnets
- Network Security Group (NSG)
- Public IP
- Network Interface
- Virtual Machine (VM)

## Terraform

- ```provider.tf```: configura o provedor Azure com os recursos necessários. Além disso, inclui configuração de backend local para armazenar o estado do Terraform.
Arquivo variables.tf:

- ```variables.tf```: nome do resource group (```student-rg```), localização (```eastus```), nome de usuário da VM (```azureuser```), e senha da VM.

- ```main.tf```:
    1. **Resource Group**:
       - Nome: ```student-rg```
    2. **Virtual Network**:
       - Nome: ```student-vnet```
       - Endereço IP: ```10.0.0.0/16```
    3. **Subnet**:
       - Nome: ```student-subnet```
       - Endereço IP: ```10.0.1.0/24```
    4. **Network Security Group**:
       - Nome: ```student-nsg```
    5. **Public IP**: 
       - Nome: ```student-pip```
    6. **Network Interface**:
       - Nome: ```student-nic```
    7. **Virtual Machine**:
       - Nome: ```student-vm```
       - Tipo de instância: Standard_B1s, SO: Ubuntu 22.04 LTS Gen2
       - Nome de usuário: ```azureuser```
       - Senha fornecida pela variável

- ```outputs.tf```: Imprime as saídas dos recursos provisionados, como o endereço IP público da VM.

## Ansible
- ```playbook.yml```:
  1. Atualiza pacotes apt.
  2. Instala o servidor web Nginx.
  3. Arquivo inventory.yml: gerado automaticamente ao aplicar o Terraform.


## Github Actions
- Configurar Segredos no GitHub:

```
ARM_CLIENT_ID
ARM_CLIENT_SECRET
ARM_SUBSCRIPTION_ID
ARM_TENANT_ID
TF_VAR_vm_admin_password 
```

- Arquivo workflow que executa:
  1. Checkout do repositório.
  2. Instala e configura o Terraform.
  3. Executa os comandos de formatação e linting do Terraform (terraform fmt, TFLint).
  4. Executa as verificações de segurança com Checkov.
  5. Inicializa e aplica os planos do Terraform.
  6. Instala o Ansible.
  7. Executa o playbook do Ansible para configurar a VM.