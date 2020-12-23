class SerializeScratchpadPage
  include Mandate

  initialize_with :page

  def call
    return if page.blank?

    {
      scratchpad_page: {
        id: page.id,
        about_type: page.about_type,
        about_id: page.about_id,
        user_id: page.user_id,
        content_markdown: page.content_markdown
      }
    }
  end
end
