module Temp
  class MentoringController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :disable_site_header!

    def student_request
      @solution = Solution.first
    end
  end
end
