module HasMarkdownField
  def has_markdown_field(fields, opts = {})
    fields = Array(fields)

    before_save do
      fields.each do |field|
        html_field = "#{field}_html"
        markdown_field = "#{field}_markdown"

        # TODO: consider what to do if the markdown field is optional
        # Do we want to not update the HTML then?
        self[html_field] = Markdown::Parse.(
          self[markdown_field],
          **opts
        )
      end
    end
  end
end
