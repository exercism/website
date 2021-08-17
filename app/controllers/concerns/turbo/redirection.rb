module Turbo
  module Redirection
    extend ActiveSupport::Concern

    def redirect_to(url = {}, options = {})
      turbo = options.delete(:turbo)

      super.tap do
        visit_location_with_turbo(location, turbo) if turbo && request.xhr? && !request.get?
      end
    end

    private
    def visit_location_with_turbo(location, action)
      visit_options = {
        action: action.to_s == "advance" ? action : "replace"
      }

      script = []
      script << "Turbo.clearCache()"
      script << "Turbo.visit(#{location.to_json}, #{visit_options.to_json})"

      self.status = 200
      self.response_body = script.join("\n")
      response.content_type = "text/javascript"
      response.headers["X-Xhr-Redirect"] = location
    end
  end
end
