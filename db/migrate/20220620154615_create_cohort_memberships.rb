class CreateCohortMemberships < ActiveRecord::Migration[7.0]
  def change
    create_table :cohort_memberships do |t|
      t.belongs_to :user, null: false, index: {unique: true}, foreign_key: true
      t.string :cohort_slug, null: false
      t.text :introduction, null: false

      t.timestamps
    end
  end
end
