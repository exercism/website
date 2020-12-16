Exercism.config.api_host =
  if Rails.env.development?
    "http://local.exercism.io:3020/api".freeze
  else
    "https://api.exercism.io".freeze
  end

Exercism.config.hcaptcha_endpoint = "https://hcaptcha.com"
