class Markdown::RenderHTML
  include Mandate

  initialize_with :doc, nofollow_links: false, heading_ids: true

  def call
    renderer = Renderer.new(options: %i[UNSAFE FOOTNOTES], nofollow_links:, heading_ids:)
    renderer.render(doc)
  end

  class Renderer < CommonMarker::HtmlRenderer
    def initialize(options:, nofollow_links: false, heading_ids: false)
      super(options:)
      @nofollow_links = nofollow_links
      @heading_ids = heading_ids
      @heading_id_counts = Hash.new(0)
    end

    private
    attr_reader :nofollow_links, :heading_ids, :heading_id_counts

    def header(node)
      return super(node) unless heading_ids

      block do
        out("<h", node.header_level, " id=\"", header_id(node), "\">", :children, "</h", node.header_level, ">")
      end
    end

    def image(node)
      m = IMAGE_URL_REGEX.match(node.url)
      return image_with_class(node) if m.nil?

      if m[:path].end_with?('-invertible')
        image_with_class(node, class_name: IMAGE_CLASS_INVERTIBLE)
      elsif m[:path].end_with?('-light')
        image_with_class(node, class_name: IMAGE_CLASS_LIGHT_THEME)
        image_with_class(node, url: "#{m[:path][0..-7]}-dark.#{m[:extension]}#{m[:query_string]}", class_name: IMAGE_CLASS_DARK_THEME)
      elsif m[:path].end_with?('-dark')
        image_with_class(node, url: "#{m[:path][0..-6]}-light.#{m[:extension]}#{m[:query_string]}",
          class_name: IMAGE_CLASS_LIGHT_THEME)
        image_with_class(node, class_name: IMAGE_CLASS_DARK_THEME)
      else
        image_with_class(node)
      end
    end

    def image_with_class(node, url: nil, class_name: nil)
      out('<img src="', escape_href(url || node.url), '"')
      plain do
        out(' alt="')
        node.each { |child| out(child) }
        out('"')
      end
      out(' title="', escape_html(node.title), '"') if node.title.present?
      out(' class="', class_name, '"') if class_name.present?
      out(' />')
    end

    def header_id(node)
      title = "h-#{header_string_content(node).join('-').parameterize}"
      unique_title = heading_id_counts[title].zero? ? title : "#{title}-#{heading_id_counts[title]}"
      heading_id_counts[title] = heading_id_counts[title] + 1
      unique_title
    end

    def header_string_content(node)
      return node.string_content if %i[text code].include?(node.type)

      node.each.map { |n| header_string_content(n) }
    end

    def link(node)
      # TODO: re-enable once we figure out how to do custom scrubbing
      # return vimeo_link(node) if vimeo_link?(node)

      uri = Addressable::URI.parse(node.url)

      out('<a href="', link_href(uri), '"')
      out(' title="', escape_html(node.title), '"') if node.title.present?
      if external_url?(uri)
        out(' target="_blank"')
        out(' rel="noreferrer', nofollow_links ? ' nofollow' : '', '"')
      else
        out(' rel="nofollow"') if nofollow_links
        out(' data-turbo="false"') if uri.fragment.present?
      end
      out(link_tooltip_attributes(node))
      out('>', :children, '</a>')
    end

    def link_href(uri)
      return '' if uri.nil?
      return escape_href(uri.to_s) if uri.fragment.blank? || uri.fragment.start_with?('h-')
      return escape_href(uri.to_s) if external_url?(uri)
      return escape_href(uri.to_s) if uri.path.present? && !HEADING_ID_PATHS_REGEX.match(uri.path)

      uri.fragment = "h-#{uri.fragment}"
      escape_href(uri.to_s)
    end

    def table(node)
      block do
        out("<div class='c-responsive-table-wrapper'>")
        super(node)
        out('</div>')
      end
    end

    def external_url?(uri)
      return false if uri.scheme.nil?
      return true unless %w[https http].include?(uri.scheme)
      return false if %w[exercism.io exercism.lol local.exercism.io exercism.org local.exercism.io].include?(uri.host)

      true
    rescue StandardError
      true
    end

    def link_tooltip_attributes(node)
      link_match = %r{^(?<url>https?://(?<local>local\.)?exercism\.(?<domain>io|lol|org))?/tracks/(?<track>[^/]+)/(?<type>concept|exercise)s/(?<slug>[^/#?]+)(?:/|[#?]\w*)?$}.match(node.url) # rubocop:disable Layout/LineLength
      return unless link_match

      endpoint = Exercism::Routes.send("tooltip_track_#{link_match[:type]}_path", link_match[:track], link_match[:slug])
      %( data-tooltip-type="#{link_match[:type]}" data-endpoint="#{endpoint}")
    end

    def code_block(node)
      return note_block(node) if NOTE_BLOCK_FENCES.include?(node.fence_info)

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

    def note_block(node)
      type = node.fence_info.split('/')[1]
      block do
        out(%(<div class="c-textblock-#{type}">))
        out(%(<div class="c-textblock-header">#{type.titleize}</div>))
        out('<div class="c-textblock-content">')
        render(Markdown::Render.(node.string_content, :doc))
        out('</div>')
        out('</div>')
      end
    end

    def vimeo_link(node)
      block do
        out('<div style="padding:56.25% 0 0 0; position:relative">')
        out(%(<iframe src="#{node.url}?badge=0&amp;autopause=0&amp;player_id=0&amp;app_id=58479" frameborder="0" allow="autoplay; fullscreen; picture-in-picture" allowfullscreen style="position:absolute;top:0;left:0;width:100%;height:100%;" title="X Exercism_ Tutorial Your first mentoring session 1.m4v">)) # rubocop:disable Layout/LineLength
        out('</iframe>')
        out('</div>')
        out('<script src="https://player.vimeo.com/api/player.js">')
        out('</script>')
      end
    end

    def vimeo_link?(node)
      return false if node.nil?

      node.url.start_with?('https://player.vimeo.com')
    end

    NOTE_BLOCK_FENCES = %w[exercism/note exercism/caution exercism/advanced].freeze
    IMAGE_URL_REGEX = /^(?<path>.+)\.(?<extension>jpe?g|png|gif|svg)(?<query_string>\?.+)?$/i
    IMAGE_CLASS_INVERTIBLE = 'c-img-invertible'.freeze
    IMAGE_CLASS_LIGHT_THEME = 'c-img-light-theme'.freeze
    IMAGE_CLASS_DARK_THEME = 'c-img-dark-theme'.freeze
    HEADING_ID_PATHS_REGEX = %r{^(/docs/|/tracks/[^/]+/(concepts|exercises)/)}
    private_constant :NOTE_BLOCK_FENCES, :IMAGE_URL_REGEX, :IMAGE_CLASS_INVERTIBLE,
      :IMAGE_CLASS_LIGHT_THEME, :IMAGE_CLASS_DARK_THEME
  end
end
