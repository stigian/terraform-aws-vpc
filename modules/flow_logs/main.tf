locals {
  # log_destination (str): The destination for the flow logs. Can be either "cloud-watch-logs" or "s3".
  log_destination = var.flow_log_definition.log_destination

  # iam_role_arn (str): The IAM role ARN to use for CloudWatch Logs. Not applicable for S3 as the bucket policy applies.
  iam_role_arn = var.flow_log_definition.log_destination_type == "cloud-watch-logs" ? var.flow_log_definition.iam_role_arn : null
}

resource "aws_flow_log" "main" {
  log_destination      = local.log_destination
  iam_role_arn         = local.iam_role_arn
  log_destination_type = var.flow_log_definition.log_destination_type
  traffic_type         = var.flow_log_definition.traffic_type
  vpc_id               = var.vpc_id

  dynamic "destination_options" {
    for_each = var.flow_log_definition.log_destination_type == "s3" ? [true] : []

    content {
      file_format                = var.flow_log_definition.destination_options.file_format
      per_hour_partition         = var.flow_log_definition.destination_options.per_hour_partition
      hive_compatible_partitions = var.flow_log_definition.destination_options.hive_compatible_partitions
    }
  }

  tags = merge(
    { Name = var.name },
    var.tags
  )
}
