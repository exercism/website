class Tracks::BuildController < ApplicationController
  include UseTrackExerciseSolutionConcern
  before_action :use_track!
  skip_before_action :authenticate_user!
  before_action :use_build_status

  def show
    @test_runner_sha = Tooling::RetrieveSha.(@track, 'test-runner')
    @representer_sha = Tooling::RetrieveSha.(@track, 'representer')
    @analyzer_sha = Tooling::RetrieveSha.(@track, 'analyzer')

    @tags = @track.analyzer_tags.order(:tag)
  end

  def syllabus_tooltip = render_template_as_json
  def representer_tooltip = render_template_as_json
  def analyzer_tooltip = render_template_as_json
  def test_runner_tooltip = render_template_as_json
  def practice_exercises_tooltip = render_template_as_json

  private
  def use_build_status
    @status = @track.build_status
  end
end
