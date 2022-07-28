class AddCohortToCohortMemberships < ActiveRecord::Migration[7.0]
  def change
    add_reference :cohort_memberships, :cohort, null: true, foreign_key: true, if_not_exists: true

    track = Track.find_by(slug: 'go') || Track.first # Guard against dev db not having Golang

    Cohort.find_create_or_find_by!(slug: 'gohort') do |c|
      c.name = 'Go-Hort'
      c.capacity = 100
      c.track = track
      c.begins_at = Time.utc(2022, 07, 01)
      c.ends_at = Time.utc(2022, 07, 30)
    end

    CohortMembership.update_all(cohort_id: Cohort.find_by(slug: :gohort).id)

    change_column_null :cohort_memberships, :cohort_id, false
  end
end
