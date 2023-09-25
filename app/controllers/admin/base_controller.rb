class Admin::BaseController < ApplicationController
  before_action :ensure_staff!

  layout "admin"
end
