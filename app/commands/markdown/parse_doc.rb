class Markdown::ParseDoc
  include Mandate

  initialize_with :text

  def call
    CommonMarker.render_doc(
      text,
      %i[DEFAULT FOOTNOTES],
      %i[table tagfilter strikethrough]
    )
  end
end
