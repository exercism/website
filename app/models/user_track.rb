class UserTrack < ApplicationRecord
  extend Mandate::Memoize
  include UserTrack::MentoringSlots

  MIN_REP_TO_TRAIN_ML = 50

  serialize :summary_data, JSON

  belongs_to :user

  # TODO: (required): Ensure this counter_cache doesn't change updated_at
  # and probably move it to a bg job as it'll be slow
  belongs_to :track, counter_cache: :num_students

  has_many :solutions, # rubocop:disable Rails/HasManyOrHasOneDependent
    lambda { |ut|
      joins(:exercise).
        where("exercises.track_id": ut.track_id)
    },
    foreign_key: :user_id,
    primary_key: :user_id,
    inverse_of: :user_track

  has_many :viewed_community_solutions, # rubocop:disable Rails/HasManyOrHasOneDependent
    ->(ut) { where(track_id: ut.track_id) },
    foreign_key: :user_id,
    primary_key: :user_id,
    inverse_of: :user_track

  has_many :viewed_exercise_approaches, # rubocop:disable Rails/HasManyOrHasOneDependent
    ->(ut) { where(track_id: ut.track_id) },
    foreign_key: :user_id,
    primary_key: :user_id,
    inverse_of: :user_track

  scope :trainer, -> { where('reputation >= ?', MIN_REP_TO_TRAIN_ML) }

  delegate :num_concepts, to: :track
  delegate :title, to: :track, prefix: true

  before_create do
    self.last_touched_at = Time.current unless self.last_touched_at
    self.summary_data = {}
  end

  # Add some caching inside here for the duration
  # of the request cycle.
  def self.for!(user_param, track_param)
    Current.user_track_for(user_param, track_param) do
      UserTrack.find_by!(
        user: User.for!(user_param),
        track: Track.for!(track_param)
      )
    end
  end

  def self.for(user_param, track_param)
    for!(user_param, track_param)
  rescue ActiveRecord::RecordNotFound
    begin
      External.new(Track.for!(track_param))
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end

  memoize
  def exercises
    enabled_exercises(track.exercises)
  end

  memoize
  def concept_exercises
    enabled_exercises(track.concept_exercises)
  end

  memoize
  def practice_exercises
    enabled_exercises(track.practice_exercises)
  end

  def concept_exercises_for_concept(concept)
    enabled_exercises(concept.concept_exercises)
  end

  def practice_exercises_for_concept(concept)
    enabled_exercises(concept.practice_exercises)
  end

  def unlockable_concepts_for_exercise(exercise)
    exercise.unlocked_concepts.to_a
  end

  def unlockable_exercises_for_exercise(exercise)
    enabled_exercises(exercise.unlocked_exercises).to_a
  end

  def unlocked_concepts_for_exercise(exercise)
    unlockable_concepts_for_exercise(exercise).filter { |c| concept_unlocked?(c) }
  end

  def unlocked_exercises_for_exercise(exercise)
    unlockable_exercises_for_exercise(exercise).filter { |e| exercise_unlocked?(e) }
  end

  def enabled_exercises(exercises)
    status = %i[active beta]
    status << :wip if maintainer?

    exercises = exercises.where(type: PracticeExercise.to_s) unless track.course? || maintainer?
    exercises.where(status:).or(exercises.where(id: solutions.select(:exercise_id))).
      includes(:track)
  end

  def course? = track.course? || (maintainer? && track.concept_exercises.exists?)

  def external? = false

  memoize
  def has_notifications?
    User::Notification.unread.
      where(user_id:, track_id:).
      exists?
  end

  def completed? = num_completed_exercises >= num_exercises
  def completed_course? = num_completed_concept_exercises >= num_concept_exercises

  def completed_percentage
    return 100.0 if num_exercises.zero?

    c = (num_completed_exercises / num_exercises.to_f) * 100
    c.denominator == 1 ? c.round : c.round(1)
  end

  def completed_concept_exercises_percentage
    return 100.0 if num_concept_exercises.zero?

    c = (num_completed_concept_exercises / num_concept_exercises.to_f) * 100
    c.denominator == 1 ? c.round : c.round(1)
  end

  def mentoring_unlocked?
    user.solutions.joins(:exercise).where.not("exercises.slug": "hello-world").where.not(type: :started).exists?
  end

  memoize
  def active_mentoring_discussions
    Mentor::Discussion.where(solution: solutions).in_progress_for_student
  end

  memoize
  def pending_mentoring_requests
    Mentor::Request.where(solution: solutions).pending
  end

  def tutorial_exercise_completed? = num_completed_exercises.positive?

  def exercise_has_notifications?(exercise)
    # None of these can have notifications
    # so avoid the expense of a db call
    return false if %i[
      locked available started
    ].include?(exercise_status(exercise))

    User::Notification.unread.
      where(user_id:, exercise_id: exercise.id).
      exists?
  end

  # In Ruby 2.7 and Ruby 3 we'll need **kwargs here.
  def method_missing(meth, *args, &block)
    summary.public_send(meth, *args, &block)
  end

  def respond_to_missing?(meth, include_all)
    return false if %i[
      to_ary
    ].include?(meth)

    summary.respond_to?(meth, include_all)
  rescue StandardError
    true # We need this for test-mocking. It's messy.
  end

  def reset_summary!
    reload
    self.summary_key = nil
    @summary = nil
  end

  memoize
  def maintainer?
    return true if user.staff? || user.admin?

    user.maintainer? && user.github_team_memberships.where(team_name: track.github_team_name).exists?
  end

  def viewed_community_solution?(exercise) = viewed_community_solutions.where(exercise:).exists?
  def viewed_approach?(exercise) = viewed_exercise_approaches.where(exercise:).exists?

  private
  # A track's summary is an efficiently created summary of all
  # of a user_track's data. It's cached across requests, allowing
  # us to quickly retrieve data without requiring lots of complex
  # SQL queries.
  def summary
    return @summary if @summary

    digest = Digest::SHA1.hexdigest(File.read(Rails.root.join('app', 'commands', 'user_track', 'generate_summary_data.rb')))
    track_updated_at = association(:track).loaded? ? track.updated_at : Track.where(id: track_id).pick(:updated_at)
    expected_key = "#{track_updated_at.to_f}:#{last_touched_at.to_f}:#{digest}"

    if summary_data.nil? || summary_key != expected_key
      # It is important to use update_columns here
      # else we'll touch updated_at and end up always
      # invalidating the cache immediately.
      update_columns(
        summary_key: expected_key,
        summary_data: UserTrack::GenerateSummaryData.(track, self)
      )
    end

    @summary = UserTrack::Summary.new(summary_data.with_indifferent_access)
  end
end
