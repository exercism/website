class CreateMentorTestimonials < ActiveRecord::Migration[7.0]
  def change
    create_table :mentor_testimonials do |t|
      t.belongs_to :mentor, null: false, foreign_key: { to_table: :users }
      t.belongs_to :student, null: false, foreign_key: { to_table: :users }
      t.belongs_to :discussion, null: false, foreign_key: { to_table: :mentor_discussions }, index: {unique: true}

      t.string :uuid, null: false, index: true

      t.text :content, null: false
      t.boolean :revealed, null: false, default: false
      t.boolean :published, null: false, default: true
      t.datetime :deleted_at, null: true

      t.timestamps
    end
  end
end
