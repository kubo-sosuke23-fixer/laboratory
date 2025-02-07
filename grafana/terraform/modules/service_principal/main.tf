resource "random_uuid" "admin" {
}

resource "random_uuid" "viewer" {
}

resource "random_uuid" "editor" {
}

resource "azuread_application" "this" {
  display_name = join("_", compact(["sp", var.product_name, var.subsystem_name, var.env]))

  app_role {
    allowed_member_types = ["User"]
    description          = "Grafana admin Users"
    display_name         = "Grafana Admin"
    enabled              = true
    id                   = random_uuid.admin.id
    value                = "Admin"
  }

  app_role {
    allowed_member_types = ["User"]
    description          = "Grafana read only Users"
    display_name         = "Grafana Viewer"
    enabled              = true
    id                   = random_uuid.viewer.id
    value                = "Viewer"
  }

  app_role {
    allowed_member_types = ["User"]
    description          = "Grafana editor Users"
    display_name         = "Grafana Editor"
    enabled              = true
    id                   = random_uuid.editor.id
    value                = "Editor"
  }

  web {
    redirect_uris = var.redirect_uris

    implicit_grant {
      id_token_issuance_enabled = true
    }
  }
}

resource "azuread_service_principal" "this" {
  client_id                    = azuread_application.this.client_id
  app_role_assignment_required = false
}

resource "azuread_application_password" "this" {
  application_id = azuread_application.this.id
  end_date       = "2099-01-01T00:00:00Z"
}
