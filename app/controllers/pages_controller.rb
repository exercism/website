class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    # solution = Solution.first
    resp = RestClient.get("https://raw.githubusercontent.com/exercism/v3-beta/main/README.md?q=#{Time.current.min}")
    @content = Markdown::Parse.(resp.body)
  end

  def health_check
    render json: { ruok: true }
  end
end
