class Test::Components::Mentoring::MentorDiscussionController < Test::BaseController
  def show
    @discussion = Solution::MentorDiscussion.find(params[:discussion_id])
  end
end
