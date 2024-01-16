class Mentor::UpdateNumFinishedDiscussions
  include Mandate

  queue_as :default
  initialize_with :mentor, :track

  def call
    # We're updating in a single query instead of two queries to avoid race-conditions
    # and using read_committed to avoid deadlocks
    ActiveRecord::Base.transaction(isolation: Exercism::READ_COMMITTED) do
      User::TrackMentorship.where(track:, user: mentor).update_all("num_finished_discussions = (#{num_finished_discussions_sql})")
    end
  end

  private
  def num_finished_discussions_sql
    Arel.sql(Mentor::Discussion.joins(:request).where(request: { track: }, mentor:).finished_for_student.select("COUNT(*)").to_sql)
  end
end
