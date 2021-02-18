class Mentoring::ExternalController < ApplicationController
  before_action :ensure_not_mentor!

  def show; end
end
