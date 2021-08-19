class Mentoring::ExternalController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :ensure_not_mentor!

  def show; end
end
