resource "mongodbatlas_privatelink_endpoint" "atlas_private_endpoint" {
  project_id    = var.atlas_project_id
  provider_name = "AWS"
  region        = var.aws_region
}

resource "aws_vpc_endpoint" "vpc_endpoint" {
  vpc_id             = aws_vpc.primary.id
  service_name       = mongodbatlas_privatelink_endpoint.atlas_private_endpoint.endpoint_service_name
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [aws_subnet.primary-az1.id, aws_subnet.primary-az2.id]
  security_group_ids = [aws_security_group.primary_default.id]
}

resource "mongodbatlas_privatelink_endpoint_service" "atlas_endpoint_service" {
  project_id          = mongodbatlas_privatelink_endpoint.atlas_private_endpoint.project_id
  endpoint_service_id = aws_vpc_endpoint.vpc_endpoint.id
  private_link_id     = mongodbatlas_privatelink_endpoint.atlas_private_endpoint.id
  provider_name       = "AWS"
}
