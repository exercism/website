class Admin::BaseController < ApplicationController
  before_action :ensure_staff!
end
