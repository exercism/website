class Cohort::Join
  include Mandate

  initialize_with :user, :cohort, :introduction

  def call
    time = Time.now.utc.to_formatted_s(:db)

    CohortMembership.connection.insert(%{
      INSERT INTO cohort_memberships (
        user_id, cohort_id, status, introduction, created_at, updated_at
      )
      SELECT
        #{user.id},
        #{cohort.id},
        IF(COUNT(*)>=#{cohort.capacity},#{ON_WAITING_LIST_STATUS},#{ENROLLED_STATUS}),
        #{ActiveRecord::Base.connection.quote(introduction)},
        "#{time}",
        "#{time}"
      FROM cohort_memberships
      WHERE cohort_id = #{cohort.id}
    })

    # The (user, cohort) pair is unique, so look the row up by it. Reading
    # back the insert id is unreliable when threads share a connection,
    # which Rails 7.2 does in transactional tests.
    CohortMembership.find_by!(user:, cohort:)
  rescue ActiveRecord::RecordNotUnique
    CohortMembership.find_by!(user:, cohort:)
  end

  ENROLLED_STATUS = CohortMembership.statuses["enrolled"]
  ON_WAITING_LIST_STATUS = CohortMembership.statuses["on_waiting_list"]

  private_constant :ENROLLED_STATUS, :ON_WAITING_LIST_STATUS
end
