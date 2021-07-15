class PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def self.readme_url
    "https://raw.githubusercontent.com/exercism/v3-beta/main/README.md?q=#{Time.current.min}"
  end

  def beta
    # solution = Solution.first
    resp = RestClient.get(self.class.readme_url)

    @content = Markdown::Parse.(resp.body)
  end

  def health_check
    render json: { ruok: true }
  end
end
