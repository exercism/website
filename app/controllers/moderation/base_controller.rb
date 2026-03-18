class Moderation::BaseController < ApplicationController
  before_action :ensure_moderator!

  layout "admin"
end
