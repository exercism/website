class AddCohortToCohortMemberships < ActiveRecord::Migration[7.0]
  def change
    add_belongs_to :cohort_memberships, :cohort, null: true, if_not_exists: true
    add_column :cohort_memberships, :status, :tinyint, default: 0, null: false, if_not_exists: true

    Cohort.find_create_or_find_by!(slug: 'gohort') do |c|
      c.name = 'Go-Hort'
      c.capacity = 100
      c.track = Track.find_by(slug: 'go')
      c.begins_at = Time.utc(2022, 07, 01)
      c.ends_at = Time.utc(2022, 07, 30)
    end

    CohortMembership.update(cohort: Cohort.find_by(slug: :cohort_slug))

    change_column_null :cohort_memberships, :cohort_id, false
  end
end
