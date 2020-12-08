module Auth
  class ConfirmationsController < Devise::ConfirmationsController
    before_action :disable_site_header!

    def required; end
  end
end
