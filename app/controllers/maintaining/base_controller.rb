class Maintaining::BaseController < ApplicationController
  before_action :ensure_maintainer!
end
