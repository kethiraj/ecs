# logs.tf

# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "cb_log_group" {
  name              = "/ecs/cb-app"
  retention_in_days = 1

  tags = {
    Name = "cb-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "cb_log_stream" {
  name           = "cb-log-stream"
  log_group_name = aws_cloudwatch_log_group.cb_log_group.name
}

resource "aws_cloudwatch_log_metric_filter" "logfilter" {
  name           = "EventCount"
  pattern        = "ERROR"
  log_group_name = aws_cloudwatch_log_group.cb_log_group.name

  metric_transformation {
    name      = "EventCount"
    namespace = "ecserrorlogs"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "error-we-care-about-alarm" {
  alarm_name = "error"
  metric_name         = aws_cloudwatch_log_metric_filter.logfilter.name
  threshold           = "0"
  statistic           = "Average"
  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = "1"
  evaluation_periods  = "1"
  period              = "60"
  namespace           = "ecserrorlogs"
  alarm_actions       = [data.aws_sns_topic.sns_topic.arn]
}
