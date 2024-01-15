class GenericExercisesController < ApplicationController
  before_action :use_exercise!, only: %i[show start edit complete tooltip no_test_runner]

  skip_before_action :authenticate_user!, only: %i[index show tooltip]
  skip_before_action :verify_authenticity_token, only: :start

  def show
    @ps_data = Git::ProblemSpecifications::Exercise.new(params[:id])
    solutions = current_user.solutions.
      includes(:exercise).
      where(exercise_id: Exercise.where(slug: params[:id])).to_a
    @num_completed_solutions = solutions.count(&:completed?)
    @solutions = solutions.index_by { |s| s.exercise.track_id }

    @track_variants = Exercise.active.where(
      slug: params[:id],
      track_id: Track.active.select(:id)
    ).includes(:track).to_a
    # @track_variants.sort_by!{ |tv| "#{@solutions[tv.track_id] ? 0 : 1}_#{tv.track.slug}"}
    @track_variants.sort_by! { |tv| tv.track.slug }

    current_week = ((Time.zone.today - Date.new(2024, 1, 16)) / 7).to_i
    return unless Date.current.year == 2024

    featured_data = User::Challenges::FeaturedExercisesProgress48In24::EXERCISES.find do |e|
      e[:slug] == @exercise.slug && e[:week] <= current_week
    end
    track_slugs = featured_data[:featured_tracks] if featured_data
    @featured_in_2024_languages = Track.where(slug: track_slugs) if track_slugs
  end

  private
  def use_exercise!
    begin
      @exercise = Track.find_by(slug: 'elixir').exercises.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      @exercise = Exercise.find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
