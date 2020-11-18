class CreateSolutionMentorDiscussionPosts < ActiveRecord::Migration[6.0]
  def change
    create_table :solution_mentor_discussion_posts do |t|
      t.belongs_to :discussion, null: false, foreign_key: {to_table: :solution_mentor_discussions}
      t.belongs_to :iteration, null: false, foreign_key: true
      t.belongs_to :user, null: false, foreign_key: true

      t.text :content_markdown, null: false
      t.text :content_html, null: false

      t.timestamps
    end
  end
end
