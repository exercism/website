class CreateMentorDiscussionPosts < ActiveRecord::Migration[7.0]
  def change
    create_table :mentor_discussion_posts do |t|
      t.string :uuid, null: false

      t.belongs_to :discussion, null: false, foreign_key: {to_table: :mentor_discussions}
      t.belongs_to :iteration, null: false, foreign_key: true
      t.belongs_to :user, null: false, foreign_key: true

      t.text :content_markdown, null: false
      t.text :content_html, null: false

      t.boolean :seen_by_student, null: false, default: false
      t.boolean :seen_by_mentor, null: false, default: false

      t.timestamps
    end
  end
end
