class SerializeScratchpadPage
  include Mandate

  initialize_with :page

  def call
    return if page.blank?

    {
      scratchpad_page: {
        id: page.uuid,
        content_markdown: page.content_markdown,
        links: {
          update: Exercism::Routes.api_scratchpad_page_url(page)
        }
      }
    }
  end
end
