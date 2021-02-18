class Test::Components::Student::MentoringSessionController < ApplicationController
  def show
    @discussion = Solution::MentorDiscussion.find(params[:discussion_id])
  end
end
