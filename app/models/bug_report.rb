class BugReport < ApplicationRecord
  belongs_to :user

  before_save do
    self.content_html = Markdown::Parse.(content_markdown)
  end
end
