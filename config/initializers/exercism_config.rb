if Rails.env.development?
  Exercism.config.api_host = "http://local.exercism.io:3020/api".freeze
else
  # TODO: Change to exercism.org
  # Exercism.config.api_host = "https://api.exercism.org".freeze
  Exercism.config.api_host = "https://exercism.org/api".freeze
end

Exercism.config.hcaptcha_endpoint = "https://hcaptcha.com"

module Exercism
  # We'll store the request context for easy access from commands
  # without having to pass it all the way down from the controller
  cattr_accessor :request_context

  # TODO: Move this upstream
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

module ScrollAxis
  X = "X".freeze
  Y = "X".freeze
end
