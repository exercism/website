if Rails.env.development?
  Exercism.config.api_host = "http://local.exercism.io:3020/api".freeze
else
  # TODO: Change to exercism.org
  # Exercism.config.api_host = "https://api.exercism.org".freeze
  Exercism.config.api_host = "https://exercism.org/api".freeze
end

Exercism.config.hcaptcha_endpoint = "https://hcaptcha.com"

# TODO: Move this upstream
module Exercism
  class ToolingJob
    def execution_exception
      data.fetch(:execution_exception, nil)
    end
  end
end

# Becuase Rails tests are run in transactions, :read_committed breaks
# in tests, so we set a constant here to use instead.
Exercism::READ_COMMITTED = Rails.env.test? ? nil : :read_committed
Exercism::READ_UNCOMMITTED = Rails.env.test? ? nil : :read_uncommitted
