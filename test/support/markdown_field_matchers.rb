module MarkdownFieldMatchers
  def assert_markdown_field(type, fields)
    fields = Array(fields)

    fields.each do |field|
      markdown_field = "#{field}_markdown"
      html_field = "#{field}_html"

      # Assert creating works
      object = build(type)
      object[markdown_field] = "Hello"
      object.save!
      assert_equal "<p>Hello</p>\n", object[html_field]

      # Assert updating works
      object[markdown_field] = "Hello 123"
      object.save!
      assert_equal "<p>Hello 123</p>\n", object[html_field]
    end
  end
end
