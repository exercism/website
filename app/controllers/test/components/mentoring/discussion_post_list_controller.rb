class Test::Components::Mentoring::DiscussionPostListController < Test::BaseController
  def show
    @discussion = Solution::MentorDiscussion.find(params[:discussion_id])
    @iteration = Iteration.find(params[:iteration_id])
  end
end
