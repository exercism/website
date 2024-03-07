class DonationsController < ApplicationController
  skip_before_action :authenticate_user!

  def index; end

  def donated; end
end
