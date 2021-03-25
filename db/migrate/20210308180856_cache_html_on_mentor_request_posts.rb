class CacheHTMLOnMentorRequestPosts < ActiveRecord::Migration[6.1]
  def change
    rename_column :solution_mentor_requests, :comment, :comment_markdown
    add_column :solution_mentor_requests, :comment_html, :text

    Solution::MentorRequest.all.each do |req|
      req.comment_markdown = "Foobar" if req.comment_markdown.blank?
      req.comment_html = Markdown::Parse.(req.comment_markdown)
      req.save!
    end

    change_column_null :solution_mentor_requests, :comment_html, false
  end
end
