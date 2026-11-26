class Admin::BaseController < ApplicationController
  before_action :ensure_maintainer!

  layout "admin"
end
