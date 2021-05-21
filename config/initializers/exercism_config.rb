if Rails.env.development?
  Exercism.config.api_host =
    "http://local.exercism.io:3020/api".freeze
else
  # TODO: Change to exercism.io
  # Exercism.config.api_host = "https://api.exercism.io".freeze
  Exercism.config.api_host = "https://exercism.lol/api".freeze
end

Exercism.config.hcaptcha_endpoint = "https://hcaptcha.com"
