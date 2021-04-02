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
      out('<a href="', node.url.nil? ? '' : escape_href(node.url), '" target="_blank"',
        nofollow_links ? '' : 'rel="noopener"')
      out(' title="', escape_html(node.title), '"') if node.title.present?
      out(' rel="nofollow"') if nofollow_links
      out(link_tooltip_attributes(node))
      out('>', :children, '</a>')
    end

    def link_tooltip_attributes(node)
      link_match = %r{^(?<url>https?://(?<local>local\.)?exercism\.(?<domain>io|lol))?/tracks/(?<track>[^/]+)/(?<type>concept|exercise)s/(?<slug>[^/#?]+)}.match(node.url) # rubocop:disable Layout/LineLength
      return unless link_match

      endpoint = Exercism::Routes.send("tooltip_track_#{link_match[:type]}_path", link_match[:track], link_match[:slug])
      %( data-tooltip-type="#{link_match[:type]}" data-endpoint="#{endpoint}")
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
