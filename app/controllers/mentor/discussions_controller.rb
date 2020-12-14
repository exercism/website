class Mentor::DiscussionsController < ApplicationController
  before_action :use_mentor_discussion
  before_action :disable_site_header!

  def show
    @solution = @mentor_discussion.solution
    @mentor = @mentor_discussion.mentor
    @student = @solution.user
    @exercise = @solution.exercise
    @track = @exercise.track
  end

  private
  def use_mentor_discussion
    @mentor_discussion = Solution::MentorDiscussion.find_by!(uuid: params[:id])

    # TODO: Redirect/show a page here
    return render(head: 403) unless @mentor_discussion.mentor_id == current_user.id
  end
end
