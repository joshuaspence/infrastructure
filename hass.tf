resource "random_string" "home_assistant_project_suffix" {
  length  = 5
  upper   = false
  special = false
}

resource "google_project" "home_assistant" {
  name       = "Home Assistant"
  project_id = "home-assistant-${random_string.home_assistant_project_suffix.result}"
  org_id     = data.google_organization.main.org_id

  # TODO: Is this needed?
  labels = {
    firebase = "enabled"
  }
}

resource "google_firebase_project" "home_assistant" {
  provider = google-beta
  project  = google_project.home_assistant.project_id
}

resource "google_service_account" "home_assistant_firebase" {
  account_id   = "firebase-adminsdk-8l3k9"
  display_name = "firebase-adminsdk"
  description  = "Firebase Admin SDK Service Agent"
  project      = google_project.home_assistant.project_id
}
