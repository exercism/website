class Admin::AdminController < ApplicationController
  before_action :ensure_staff!

  # GET /admin
  def index; end
end
