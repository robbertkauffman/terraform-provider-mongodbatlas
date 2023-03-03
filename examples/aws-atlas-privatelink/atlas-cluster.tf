# Comment entire file if you want to set up PrivateLink with an existing cluster
resource "mongodbatlas_cluster" "cluster-atlas" {
  project_id   = var.atlas_project_id
  name         = "cluster-atlas"
  cluster_type = "REPLICASET"
  replication_specs {
    num_shards = 1
    regions_config {
      region_name     = var.atlas_region
      electable_nodes = 3
      priority        = 7
      read_only_nodes = 0
    }
  }
  # Provider settings
  provider_name               = "AWS"
  provider_instance_size_name = "M10"
}

data "mongodbatlas_cluster" "cluster-atlas" {
  project_id = var.atlas_project_id
  name       = mongodbatlas_cluster.cluster-atlas.name
  depends_on = [mongodbatlas_privatelink_endpoint_service.atlas_endpoint_service]
}

# output "atlas_connstrings" {
#   value = data.mongodbatlas_cluster.cluster-atlas.connection_strings
# }

output "atlas_pe_connstring" {
  value = lookup(data.mongodbatlas_cluster.cluster-atlas.connection_strings[0].aws_private_link_srv, aws_vpc_endpoint.vpc_endpoint.id)
}
