module Auth
  class PasswordsController < Devise::PasswordsController
    before_action :disable_site_header!
  end
end
