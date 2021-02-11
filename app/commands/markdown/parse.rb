class Markdown::Parse
  include Mandate

  # TODO: This needs fixing in mandate but I don't know
  # how to do it without breaking hashes passed as the
  # last argument
  def self.call(*args, **kwargs)
    new(*args, **kwargs).()
  end

  def initialize(text, nofollow_links: false, strip_h1: true) # rubocop:disable Naming/VariableNumber
    # TODO: We almost certainly don't want to do this!
    # but for now let's reduce the heading level of all
    # headings, as they're too high in the actual docs atm
    @text = text.to_s.gsub(/^##/, '###')
    @nofollow_links = nofollow_links
    @strip_h1 = strip_h1 # rubocop:disable Naming/VariableNumber
  end

  def call
    return "" if text.blank?

    sanitized_html
  end

  private
  attr_reader :text, :nofollow_links, :strip_h1 # rubocop:disable Naming/VariableNumber

  memoize
  def sanitized_html
    Loofah.fragment(raw_html).scrub!(:escape).to_s
  end

  memoize
  def raw_html
    preprocessed_text = Markdown::Preprocess.(text, strip_h1: strip_h1) # rubocop:disable Naming/VariableNumber
    doc = Markdown::RenderDoc.(preprocessed_text)
    Markdown::Render.(doc, nofollow_links)
  end
end
