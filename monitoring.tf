resource "google_monitoring_notification_channel" "email" {
  display_name = "Test Notification Channel"
  type         = "email"
  project      = module.project.project_id
  labels = {
    email_address = "kushii.awachar@gmail.com"
  }
}

resource "google_monitoring_alert_policy" "alert_policy" {
  display_name = "CPU Utilization > 50%"
  project      = module.project.project_id
  documentation {
    content = "The CPU utilization for $${module.project.project_id} has exceeded 50% for over 1 minute."
  }
  combiner = "OR"
  conditions {
    display_name = "Condition 1"
    condition_threshold {
      comparison      = "COMPARISON_GT"
      duration        = "60s"
      filter          = "resource.type = \"gce_instance\" AND metric.type = \"compute.googleapis.com/instance/cpu/utilization\""
      threshold_value = "0.5"
      trigger {
        count = "1"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.name]

  user_labels = {
    severity = "warning"
  }
}
resource "google_monitoring_alert_policy" "memory_alert_policy" {
  display_name = "Memory Utilization > 50%"
  project      = module.project.project_id
  documentation {
    content = "The Memory utilization for $${module.project.project_id} has exceeded 50% for over 1 minute."
  }
  combiner = "OR"
  conditions {
    display_name = "Condition 1"
    condition_threshold {
      comparison      = "COMPARISON_GT"
      duration        = "60s"
      filter          = "resource.type = \"cloudsql_database\" AND metric.type = \"cloudsql.googleapis.com/database/memory/utilization\""
      threshold_value = "0.5"
      trigger {
        count = "1"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.name]

  user_labels = {
    severity = "warning"
  }
}
resource "google_project_iam_member" "monitoring_notification" {
  project = module.project.project_id
  role    = "roles/monitoring.editor"
  member  = "serviceAccount:${google_service_account.service_account.email}"

}
resource "google_project_iam_member" "monitoring_alert" {
  project = module.project.project_id
  role    = "roles/monitoring.notificationChannelEditor"
  member  = "serviceAccount:${google_service_account.service_account.email}"

}