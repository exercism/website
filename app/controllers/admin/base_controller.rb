class Admin::BaseController < ApplicationController
  before_action :ensure_staff!
  before_action :redirect_to_english!

  layout "admin"
end
