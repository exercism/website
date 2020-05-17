module HasMarkdownField
  def has_markdown_field(fields)
    fields = Array(fields)

    before_save do
      fields.each do |field|
        html_field = "#{field}_html"
        markdown_field = "#{field}_markdown"

        self[html_field] = ParseMarkdown.(self[markdown_field])
      end
    end
  end
end
