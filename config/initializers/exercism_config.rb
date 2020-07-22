aws_config = Rails.application.config_for(:aws)
services_config = Rails.application.config_for(:services)

Exercism.config.aws_auth = {
  access_key_id: ENV["AWS_ACCESS_KEY_ID"],
  secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
  profile: aws_config[:profile],
  region: aws_config[:region]
}

Exercism.config.aws_iterations_bucket = aws_config[:iterations_bucket]
Exercism.config.test_runner_orchestrator_url = services_config[:test_runner_orchestrator_url]
Exercism.config.analyzer_orchestrator_url = services_config[:analyzer_orchestrator_url]
Exercism.config.representer_orchestrator_url = services_config[:representer_orchestrator_url]
