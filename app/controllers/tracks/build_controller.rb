class Tracks::BuildController < ApplicationController
  include UseTrackExerciseSolutionConcern
  before_action :use_track!
  skip_before_action :authenticate_user!

  def show
    @status = @track.build_status
  end

  def syllabus_tooltip = render_template_as_json
  def representer_tooltip = render_template_as_json
  def analyzer_tooltip = render_template_as_json
  def test_runner_tooltip = render_template_as_json
  def practice_exercises_tooltip = render_template_as_json
end
