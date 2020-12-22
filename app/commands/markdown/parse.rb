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
    doc = CommonMarker.render_doc(
      preprocessed_text,
      :DEFAULT,
      %i[table tagfilter strikethrough]
    )
    renderer = Renderer.new(options: [:UNSAFE], nofollow_links: nofollow_links)
    renderer.render(doc)
  end

  memoize
  def preprocessed_text
    text.gsub(/^`{3,}(.*?)`{3,}\s*$/m) { "\n#{Regexp.last_match(0)}\n" }
  end

  class Renderer < CommonMarker::HtmlRenderer
    def initialize(options:, nofollow_links: false)
      super(options: options)
      @nofollow_links = nofollow_links
    end

    private
    attr_reader :nofollow_links

    def link(node)
      out('<a href="', node.url.nil? ? '' : escape_href(node.url), '" target="_blank"')
      out(' title="', escape_html(node.title), '"') if node.title.present?
      out(' rel="nofollow"') if nofollow_links
      out('>', :children, '</a>')
    end

    def code_block(node)
      block do
        out("<pre#{sourcepos(node)}><code")
        if node.fence_info.present?
          out(' class="language-', node.fence_info.split(/\s+/)[0], '">')
        else
          out(' class="language-plain">')
        end
        out(escape_html(node.string_content))
        out('</code></pre>')
      end
    end
  end
end
