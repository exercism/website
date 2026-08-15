class Tracks::BuildController < ApplicationController
  include UseTrackExerciseSolutionConcern
  before_action :use_track!
  skip_before_action :authenticate_user!
  before_action :use_build_status
  before_action :cache_show_action!, only: %i[show]

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
  # The build page is regenerated nightly by UpdateTracksBuildStatusJob, which
  # purges it (see Track::InvalidateCloudflareCache), so a day at the edge is
  # safe. It is also the most expensive page we serve anonymously: three
  # Tooling::RetrieveSha network calls per request.
  def cache_show_action! = cache_public_action!(edge_ttl: 1.day)

  def use_build_status
    @status = @track.build_status
  end
end
