class Markdown::RenderHTML
  include Mandate

  initialize_with :doc, :nofollow_links

  def call
    renderer = Renderer.new(options: [:UNSAFE], nofollow_links: nofollow_links)
    renderer.render(doc)
  end

  class Renderer < CommonMarker::HtmlRenderer
    def initialize(options:, nofollow_links: false)
      super(options: options)
      @nofollow_links = nofollow_links
    end

    private
    attr_reader :nofollow_links

    def link(node)
      inline_link_match = match_inline_link(node)

      out('<a href="', node.url.nil? ? '' : escape_href(node.url), '" target="_blank"')
      out(' title="', escape_html(node.title), '"') if node.title.present?
      out(' rel="nofollow"') if nofollow_links
      out(" data-react-inline-link=\"#{inline_link_match[:link]}\"") if inline_link_match
      out('>', :children, '</a>')
    end

    def match_inline_link(node)
      %r{^(?<url>https://exercism.io)?/tracks/(?<link>[a-zA-Z0-9_-]+/(?<type>concepts|exercises)/[a-zA-Z0-9_-]+)}.match(node.url) # rubocop:disable Layout/LineLength
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
