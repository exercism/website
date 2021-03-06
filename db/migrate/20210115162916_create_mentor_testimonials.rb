class CreateMentorTestimonials < ActiveRecord::Migration[6.1]
  def change
    create_table :mentor_testimonials do |t|
      t.belongs_to :mentor, null: false, foreign_key: { to_table: :users }
      t.belongs_to :student, null: false, foreign_key: { to_table: :users }

      t.belongs_to :discussion, null: false, foreign_key: { to_table: :solution_mentor_discussions }, index: {unique: true}

      t.text :content, null: false

      t.timestamps
    end
  end
end
