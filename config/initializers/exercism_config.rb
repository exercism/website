if Rails.env.development?
  begin
    YAML.load_file(Rails.root / "config/settings.local.yml").tap do |config|
      (config["config"] || {}).each do |key, value|
        Exercism.config.send("#{key}=", value.freeze)
      end
      (config["secrets"] || {}).each do |key, value|
        Exercism.secrets.send("#{key}=", value.freeze)
      end
    end
  rescue Errno::ENOENT
    # It's ok to not have a local files endpoint
  end

  Exercism.config.api_host = "http://local.exercism.io:3020/api".freeze
else
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
