class AddExternalToMentorRequestAndDiscussion < ActiveRecord::Migration[7.0]
  def change
    add_column :mentor_requests, :external, :boolean, default: false, null: false, if_not_exists: true
    add_column :mentor_discussions, :external, :boolean, default: false, null: false, if_not_exists: true

    unless Rails.env.production?
      Mentor::Request.where(comment_markdown: "This is a private review session").update_all(external: true)
      Mentor::Discussion.joins(:request).where('request.external': true).update_all(external: true)
    end
  end
end
