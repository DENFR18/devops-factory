data "azurerm_client_config" "current" {}

locals {
  prefix = "${var.project_name}-${var.environment}"
  tags = {
    project     = var.project_name
    environment = var.environment
    managed_by  = "terraform"
  }

  # Namespaces multi-tenant — 1 par stack cliente + infra
  namespaces = {
    "esn-portal"       = { cpu = "500m", ram = "512Mi" }
    "stack-wordpress"  = { cpu = "1",    ram = "1Gi"   }
    "stack-ghost"      = { cpu = "500m", ram = "512Mi" }
    "stack-gitea"      = { cpu = "500m", ram = "512Mi" }
    "stack-nextcloud"  = { cpu = "1",    ram = "1Gi"   }
    "stack-node-api"   = { cpu = "250m", ram = "256Mi" }
    "stack-flask"      = { cpu = "250m", ram = "256Mi" }
    "stack-react"      = { cpu = "250m", ram = "256Mi" }
    "stack-mattermost" = { cpu = "1",    ram = "1Gi"   }
    "stack-sonarqube"  = { cpu = "2",    ram = "2Gi"   }
    "stack-minio"      = { cpu = "500m", ram = "512Mi" }
    "monitoring"       = { cpu = "1",    ram = "1Gi"   }
    "logging"          = { cpu = "1",    ram = "1Gi"   }
  }
}

# ─── Resource Group ───────────────────────────────────────────────────────────

resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.prefix}"
  location = var.location
  tags     = local.tags
}

# ─── Log Analytics Workspace ──────────────────────────────────────────────────

resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-${local.prefix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_analytics_retention_days
  tags                = local.tags
}

# ─── Azure Container Registry ─────────────────────────────────────────────────

resource "azurerm_container_registry" "acr" {
  name                = replace("acr${local.prefix}", "-", "")
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = false
  tags                = local.tags
}

# ─── Virtual Network ──────────────────────────────────────────────────────────

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${local.prefix}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.tags
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "snet-aks-${local.prefix}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# ─── AKS Cluster ──────────────────────────────────────────────────────────────

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-${local.prefix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${local.prefix}-k8s"
  kubernetes_version  = var.kubernetes_version
  tags                = local.tags

  default_node_pool {
    name                = "default"
    enable_auto_scaling = true
    min_count           = var.aks_min_node_count
    max_count           = var.aks_max_node_count
    vm_size             = var.aks_node_vm_size
    vnet_subnet_id      = azurerm_subnet.aks_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    service_cidr      = "10.1.0.0/16"
    dns_service_ip    = "10.1.0.10"
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  }
}

# ─── Allow AKS to pull images from ACR ───────────────────────────────────────

resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

# ─── Key Vault ────────────────────────────────────────────────────────────────

resource "azurerm_key_vault" "kv" {
  name                       = "kv-${local.prefix}"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  tags                       = local.tags
}

# Accès pour l'exécuteur Terraform (CI/CD service principal ou utilisateur courant)
resource "azurerm_key_vault_access_policy" "terraform_executor" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = ["Get", "List", "Set", "Delete", "Purge"]
}

# Accès pour la managed identity AKS (lecture des secrets dans les pods)
resource "azurerm_key_vault_access_policy" "aks_identity" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id

  secret_permissions = ["Get", "List"]
}

# ─── Kubernetes Namespaces (multi-tenant) ─────────────────────────────────────

resource "kubernetes_namespace" "stacks" {
  for_each = local.namespaces

  metadata {
    name = each.key
    labels = {
      "managed-by"  = "terraform"
      "project"     = var.project_name
      "environment" = var.environment
    }
  }

  depends_on = [azurerm_kubernetes_cluster.aks]
}

# ResourceQuota : limite CPU + RAM par namespace
resource "kubernetes_resource_quota" "stacks" {
  for_each = local.namespaces

  metadata {
    name      = "quota-${each.key}"
    namespace = kubernetes_namespace.stacks[each.key].metadata[0].name
  }

  spec {
    hard = {
      "limits.cpu"    = each.value.cpu
      "limits.memory" = each.value.ram
    }
  }
}

# LimitRange : valeurs par défaut par container
resource "kubernetes_limit_range" "stacks" {
  for_each = local.namespaces

  metadata {
    name      = "limits-${each.key}"
    namespace = kubernetes_namespace.stacks[each.key].metadata[0].name
  }

  spec {
    limit {
      type = "Container"
      default = {
        cpu    = each.value.cpu
        memory = each.value.ram
      }
      default_request = {
        cpu    = "100m"
        memory = "128Mi"
      }
    }
  }
}
