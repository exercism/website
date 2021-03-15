class DocsController < ApplicationController
  skip_before_action :authenticate_user!

  def index; end

  def show; end
end
