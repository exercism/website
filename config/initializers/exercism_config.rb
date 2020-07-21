class ExercismConfig
  include Singleton

  def aws_auth
    {
      access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
      profile: aws_config[:profile],
      region: aws_config[:region]
    }
  end

  def aws_iterations_bucket
    aws_config[:iterations_bucket]
  end

  def test_runner_orchestrator_url
    services_config[:test_runner_orchestrator_url]
  end

  def analyzer_orchestrator_url
    services_config[:analyzer_orchestrator_url]
  end

  def representer_orchestrator_url
    services_config[:representer_orchestrator_url]
  end

  private
  def aws_config
    Rails.application.config_for(:aws)
  end

  def services_config
    Rails.application.config_for(:services)
  end
end

module Exercism
  def self.config
    ExercismConfig.instance
  end
end
