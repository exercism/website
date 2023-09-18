module HasMarkdownField
  def has_markdown_field(fields, opts = {})
    fields = Array(fields)

    before_save do
      fields.each do |field|
        html_field = "#{field}_html"
        markdown_field = "#{field}_markdown"

        self[html_field] = self[markdown_field].nil? ? nil : Markdown::Parse.(self[markdown_field], **opts)
      end
    end
  end
end
