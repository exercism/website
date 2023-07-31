class Mentoring::DiscussionsController < ApplicationController
  before_action :ensure_mentor!
  before_action :use_mentor_discussion

  def show
    @solution = @mentor_discussion.solution
    @mentor = @mentor_discussion.mentor
    @student = @solution.user
    @exercise = @solution.exercise
    @track = @exercise.track
  end

  private
  def use_mentor_discussion
    @mentor_discussion = Mentor::Discussion.find_by!(uuid: params[:id])

    # TODO: (Required) Do we want an unauthorised page here?
    redirect_to mentoring_path unless @mentor_discussion.viewable_by_mentor?(current_user)
  end
end
