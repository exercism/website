Exercism.config.dynamodb_client =
  Aws::DynamoDB::Client.new(Exercism.config.aws_settings)

Exercism.config.tooling_jobs_table = 
  Rails.env.test? ? "tooling_jobs-test" : :tooling_jobs
