class CreateIterationDiscussionPosts < ActiveRecord::Migration[6.0]
  def change
    create_table :iteration_discussion_posts do |t|
      t.belongs_to :iteration, null: false, foreign_key: true
      t.belongs_to :discussion, polymorphic: true, index: {name: "discussion_post_discussion_idx"}, null: false
      t.text :content_markdown, null: false
      t.text :content_html, null: false

      t.timestamps
    end
  end
end
