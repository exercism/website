class Markdown::Parse
  include Mandate

  # TODO: This needs fixing in mandate but I don't know
  # how to do it without breaking hashes passed as the
  # last argument
  def self.call(*args, **kwargs)
    new(*args, **kwargs).()
  end

  def initialize(text, nofollow_links: false)
    # TODO: We almost certainly don't want to do this!
    # but for now let's reduce the heading level of all
    # headings, as they're too high in the actual docs atm
    @text = text.to_s.gsub(/^##/, '###')
    @nofollow_links = nofollow_links
  end

  def call
    return "" if text.blank?

    sanitized_html
  end

  private
  attr_reader :text, :nofollow_links

  memoize
  def sanitized_html
    Loofah.fragment(raw_html).scrub!(:escape).to_s
  end

  memoize
  def raw_html
    preprocessed_text = Markdown::Preprocess.(text)
    doc = Markdown::RenderDoc.(preprocessed_text)
    Markdown::Render.(doc, nofollow_links)
  end
end
