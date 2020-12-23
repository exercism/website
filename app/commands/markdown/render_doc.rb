class Markdown::RenderDoc
  include Mandate

  initialize_with :preprocessed_text

  def call
    CommonMarker.render_doc(
      preprocessed_text,
      :DEFAULT,
      %i[table tagfilter strikethrough]
    )
  end
end
