class SerializeScratchpadPage
  include Mandate

  initialize_with :page

  def call
    {
      scratchpad_page: {
        content_markdown: page.content_markdown
      }
    }
  end
end
