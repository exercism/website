class AssembleExerciseWidget < Assembler
  include Mandate

  def initialize(exercise, user_track,
                 with_tooltip:, render_blurb:, render_track:, recommended:, skinny:, solution: nil)
    super()

    @exercise = exercise
    @user_track = user_track
    @solution = solution
    @with_tooltip = with_tooltip
    @render_blurb = render_blurb
    @render_track = render_track
    @recommended = recommended
    @skinny = skinny
  end

  def call
    {
      exercise: SerializeExercise.(exercise, user_track:, recommended:),
      track: render_track ? SerializeTrack.(exercise.track, user_track) : nil,
      solution: solution ? SerializeSolution.(solution, user_track:) : nil,
      links:,
      render_blurb:,
      skinny:
    }
  end

  private
  attr_reader :exercise, :user_track, :solution, :with_tooltip, :render_blurb, :render_track,
    :recommended, :skinny

  def links
    {
      tooltip: with_tooltip ? Exercism::Routes.tooltip_track_exercise_path(exercise.track, exercise) : nil
    }.compact
  end
end
