class Test::Components::Mentoring::DiscussionController < Test::BaseController
  def show
    @discussion = Mentor::Discussion.find(params[:discussion_id])
  end
end
