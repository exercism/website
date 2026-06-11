module API
  module Jiki
    class BaseController < API::BaseController
      skip_before_action :authenticate_user!, raise: false

      before_action :authenticate_jiki!

      private
      def authenticate_jiki!
        expected = Exercism.secrets.jiki_api_key.to_s
        return render_401 if expected.blank?

        header = request.headers['Authorization'].to_s
        token = header.match(/^Bearer\s+(.+)$/)&.captures&.first.to_s

        render_401 unless ActiveSupport::SecurityUtils.secure_compare(token, expected)
      end
    end
  end
end
