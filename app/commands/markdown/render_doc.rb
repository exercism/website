class Markdown::RenderDoc
  include Mandate

  initialize_with :text

  def call
    CommonMarker.render_doc(
      text,
      :DEFAULT,
      %i[table tagfilter strikethrough]
    )
  end
end
