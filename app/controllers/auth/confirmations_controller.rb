module Auth
  class ConfirmationsController < Devise::ConfirmationsController
    def required; end
  end
end
