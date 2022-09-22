####################################################################################################
## OpenSearch Certs: Resources for creating OpenSearch certificates
####################################################################################################

# Documentatiion for how to generate these certificates can be found here
# https://opensearch.org/docs/latest/security-plugin/configuration/generate-certificates/
# Unfortunately, Terraform doesn't generate PKCS8 keys which are required
# for the TLS private key, so we have to hack the external data to make it work.
# TODO: It might be possible to use cert-manager to generate these instead if a valid domain
# is provided.

resource "tls_private_key" "opensearch_root_ca_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "opensearch_root_ca_cert" {
  private_key_pem   = tls_private_key.opensearch_root_ca_key.private_key_pem
  is_ca_certificate = true

  subject {
    common_name         = "groveca"
    organization        = "OpenCraft"
    organizational_unit = "Grove"
    locality            = "Berlin"
    province            = "Berlin"
    country             = "DE"
  }

  validity_period_hours = 24 * 365 * 5

  allowed_uses = [
    "digital_signature",
    "cert_signing",
    "crl_signing",
  ]
}

resource "tls_private_key" "opensearch_admin_key" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

# Terraform doesn't support generating pkcs8 certificates out of the box
# https://github.com/hashicorp/terraform-provider-tl\s/issues/55
data "external" "opensearch_admin_key_pkcs8" {
  depends_on = [tls_private_key.opensearch_admin_key]
  program = [
    "/bin/sh",
    "${path.module}/java_key.sh",
    "${tls_private_key.opensearch_admin_key.private_key_pem}"
  ]
}

resource "tls_cert_request" "opensearch_admin_csr" {
  private_key_pem = tls_private_key.opensearch_admin_key.private_key_pem

  subject {
    common_name         = "ADMIN"
    organization        = "OpenCraft"
    organizational_unit = "Grove"
    locality            = "Berlin"
    province            = "Berlin"
    country             = "DE"
  }
}

resource "tls_locally_signed_cert" "opensearch_admin_cert" {
  cert_request_pem   = tls_cert_request.opensearch_admin_csr.cert_request_pem
  ca_private_key_pem = tls_private_key.opensearch_root_ca_key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.opensearch_root_ca_cert.cert_pem

  validity_period_hours = 5 * 365 * 24

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]
}

resource "kubernetes_secret" "opensearch_http_certificates" {
  metadata {
    name      = "opensearch-http-certificates"
    namespace = local.namespace_monitoring
  }
  data = {
    "tls.key" = data.external.opensearch_admin_key_pkcs8.result.converted
    "tls.crt" = tls_locally_signed_cert.opensearch_admin_cert.cert_pem
    "ca.crt"  = tls_self_signed_cert.opensearch_root_ca_cert.cert_pem
  }
  type = "Opaque"
}
