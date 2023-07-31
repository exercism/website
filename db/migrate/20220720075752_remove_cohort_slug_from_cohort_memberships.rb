class RemoveCohortSlugFromCohortMemberships < ActiveRecord::Migration[7.0]
  def change
    remove_column :cohort_memberships, :cohort_slug, :string
  end
end
