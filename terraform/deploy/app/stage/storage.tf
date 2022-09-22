####################################################################################################
## An S3-like bucket to store the Tutor "state" (env folders)
####################################################################################################


module "tutor_env" {
  source        = "./spaces"
  bucket_prefix = "tenv-${replace(var.cluster_name, "_", "-")}"
  do_region     = var.do_region
}

output "tutor_env_bucket" {
  sensitive = false
  value     = module.tutor_env.spaces_bucket.name
}




####################################################################################################
## Create the necessary S3 buckets
####################################################################################################

module "instance_edxapp_bucket" {
  for_each = toset(var.tutor_instances)

  source        = "./spaces"
  bucket_prefix = join("-", ["edx", replace(var.cluster_name, "_", "-"), replace(each.key, "_", "-")])
  do_region     = var.do_region
}


output "edxapp_bucket" {
  sensitive = true
  value     = { for instance in var.tutor_instances : instance => module.instance_edxapp_bucket[instance] }
}
