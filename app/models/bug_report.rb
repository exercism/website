class BugReport < ApplicationRecord
  belongs_to :user

  before_save do
    self.content_html = ParseMarkdown.(content_markdown)
  end
end
