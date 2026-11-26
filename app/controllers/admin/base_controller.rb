class Admin::BaseController < ApplicationController
  before_action :ensure_maintainer_admin!

  layout "admin"
end
