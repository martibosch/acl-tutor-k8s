terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">=2.19"
    }
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 8
}

resource "digitalocean_spaces_bucket" "spaces_bucket" {
  name          = "${var.bucket_prefix}-${random_id.bucket_suffix.dec}"
  region        = var.do_region
  acl           = "private"
  force_destroy = true

  # Versioning protects us from accidental file deletion and override. Lifecycle rules clean up old file versions.
  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true

    expiration {
      # Delete files that have no available versions.
      expired_object_delete_marker = true
    }

    noncurrent_version_expiration {
      days = 30
    }
  }
}
