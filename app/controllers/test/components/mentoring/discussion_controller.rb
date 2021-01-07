class Test::Components::Mentoring::DiscussionController < Test::BaseController
  def show
    @discussion = Solution::MentorDiscussion.find(params[:discussion_id])
  end
end
