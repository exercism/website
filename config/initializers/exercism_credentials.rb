module ExercismCredentials
  def self.aws_auth
    {
      access_key_id: aws[:access_key_id],
      secret_access_key: aws[:secret_access_key],
      region: aws[:region]
    }
  end

  def self.aws_iterations_bucket
    aws[:iterations_bucket]
  end

  def self.aws
    Rails.application.config_for(:aws)
  end
end

