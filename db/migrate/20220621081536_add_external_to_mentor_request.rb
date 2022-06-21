class AddExternalToMentorRequest < ActiveRecord::Migration[7.0]
  def change
    add_column :mentor_requests, :external, :boolean, default: false, null: false, if_not_exists: true

    Mentor::Request.where(comment_markdown: "This is a private review session").update_all(external: true)
  end
end
