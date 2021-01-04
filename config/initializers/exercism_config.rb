if Rails.env.development?
  Exercism.config.api_host =
    "http://local.exercism.io:3020/api".freeze
else
  Exercism.config.api_host =
    "https://api.exercism.io".freeze
end

Exercism.config.hcaptcha_endpoint = "https://hcaptcha.com"
