module Temp
  class MentoringController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :disable_site_header!

    def student_request
      @solution = Solution.first
      @first_time_on_track = true
      @first_time_mentoring = true
    end
  end
end
