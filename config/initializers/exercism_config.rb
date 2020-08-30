Exercism.config.api_host = if Rails.env.development?
                             "http://localhost:3020/api".freeze
                           else
                             "https://api.exercism.io".freeze
                           end
