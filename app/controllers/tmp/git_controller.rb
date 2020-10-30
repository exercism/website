class Tmp::GitController < ApplicationController
  def pull
    url = "#{Exercism.config.git_server_url}/pull"
    RestClient.post(url, {})
  end
end

