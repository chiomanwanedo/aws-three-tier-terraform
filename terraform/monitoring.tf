resource "aws_sns_topic" "three_tier_topic" {
  name = "aws-three-tier-topic"
}


resource "aws_sns_topic_subscription" "three_tier_sns_subscription" {
  topic_arn = aws_sns_topic.three_tier_topic.arn
  protocol  = "email"
  endpoint  = "chiomavanessa8@gmail.com"
}


resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name          = "three-tier-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 50
  alarm_actions       = [aws_sns_topic.three_tier_topic.arn]
  dimensions = {
    ClusterName = aws_ecs_cluster.ecs_cluster.name
    ServiceName = aws_ecs_service.ecs_service.name
  }
}


resource "aws_cloudwatch_metric_alarm" "alb" {
  alarm_name          = "alb-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  namespace           = "AWS/ApplicationELB"
  metric_name         = "UnHealthyHostCount"
  period              = 60
  statistic           = "Maximum"
  threshold           = 1
  alarm_actions       = [aws_sns_topic.three_tier_topic.arn]
  dimensions = {
    LoadBalancer = aws_lb.alb.arn_suffix
    TargetGroup  = aws_lb_target_group.alb_target_group.arn_suffix
  }
}



resource "aws_cloudwatch_metric_alarm" "aurora" {
  alarm_name          = "aurora-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  namespace           = "AWS/RDS"
  metric_name         = "DatabaseConnections"
  period              = 60
  statistic           = "Average"
  threshold           = 20
  alarm_actions       = [aws_sns_topic.three_tier_topic.arn]
  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.rds_aurora.cluster_identifier
  }
}



resource "aws_iam_role" "grafana_cloudwatch_role" {
  name               = "grafana-cloudwatch-readonly"
  assume_role_policy = data.aws_iam_policy_document.grafana_assume_role_trust.json
}


data "aws_iam_policy_document" "grafana_assume_role_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::008923505280:root"]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = ["1387272"]
    }
  }
}



data "aws_iam_policy_document" "grafana_cloudwatch_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricData",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:DescribeAlarmsForMetric",
      "cloudwatch:DescribeAlarms",
      "tag:GetResources",
    ]
    resources = ["*"]
  }
}


resource "aws_iam_role_policy" "grafana_cloudwatch_policy" {
  name   = "grafana-cloudwatch-policy"
  role   = aws_iam_role.grafana_cloudwatch_role.name
  policy = data.aws_iam_policy_document.grafana_cloudwatch_permissions.json
}


