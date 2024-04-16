class GenericExercisesController < ApplicationController
  before_action :use_exercise!, only: %i[show approaches]
  skip_before_action :authenticate_user!, only: %i[show approaches]

  def show
    @track_variants = Exercise.available.where(
      slug: params[:id],
      track_id: Track.active.select(:id)
    ).includes(:track).to_a
    @track_variants.sort_by! { |tv| tv.track.slug }

    if current_user
      solutions = current_user.solutions.
        includes(:exercise).
        where(exercise_id: Exercise.where(slug: params[:id])).to_a
      @num_completed_solutions = solutions.count(&:completed?)
      @solutions = solutions.index_by { |s| s.exercise.track_id }
    else
      @solutions = {}
      @num_completed_solutions = 0
    end

    if Date.current.year == 2024 # rubocop:disable Style/GuardClause
      current_week = ((Time.zone.today - Date.new(2024, 1, 15)) / 7).ceil

      featured_data = User::Challenges::FeaturedExercisesProgress48In24::EXERCISES.find do |e|
        e[:slug] == @exercise.slug && e[:week] <= current_week
      end
      track_slugs = featured_data[:featured_tracks] if featured_data
      @featured_in_2024_languages = Track.where(slug: track_slugs) if track_slugs
    end
  end

  def approaches
    @approaches = Exercise::Approach.includes(:exercise, :track).joins(:exercise).
      where(exercise: { slug: params[:id] }).
      group_by(&:slug).
      to_h.
      transform_values { |approaches| approaches.sort_by { |a| a.track.title } }.
      sort
  end

  private
  def use_exercise!
    begin
      @exercise = Track.find_by(slug: 'elixir').exercises.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      @exercise = Exercise.find(params[:id])
    end

    @ps_data = @exercise.generic_exercise
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
