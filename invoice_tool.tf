resource "random_string" "invoice_tool_project_suffix" {
  length  = 5
  upper   = false
  special = false
}

resource "google_project" "invoice_tool" {
  name       = "Invoice Tool"
  project_id = "invoice-tool-${random_string.invoice_tool_project_suffix.result}"
  org_id     = data.google_organization.main.org_id
}

resource "google_project_service" "invoice_tool_gmail" {
  project = google_project.invoice_tool.project_id
  service = "gmail.googleapis.com"
}

output "invoice_tool_oauth_setup" {
  description = "Console steps for the invoices Gmail OAuth client, which have no API."
  value       = <<-EOT

    1. Consent screen, user type INTERNAL:
       https://console.cloud.google.com/auth/overview?project=${google_project.invoice_tool.project_id}

    2. Add scope https://www.googleapis.com/auth/gmail.readonly
       A demand for verification here means falling back to IMAP.

    3. OAuth client ID, application type "Desktop app":
       https://console.cloud.google.com/auth/clients?project=${google_project.invoice_tool.project_id}

    4. GOOGLE_CLIENT_ID=... GOOGLE_CLIENT_SECRET=... \
         node <claude-plugins>/plugins/invoices/scripts/gmail-spike.mjs auth

  EOT
}
