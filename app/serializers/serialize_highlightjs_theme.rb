# Extracts the highlight.js scope -> style mapping out of our own theme CSS.
#
# The image generator renders solution images without a browser, so it can't
# rely on a stylesheet to colour the code. It needs the colours as data. Pulling
# them out of the CSS rather than keeping a second hand-written copy means the
# stylesheet stays the single source of truth - restyle the theme and the images
# follow, instead of silently drifting.
class SerializeHighlightjsTheme
  include Mandate

  CSS_PATH = Rails.root.join('app', 'css', 'highlighters', 'highlightjs-dark.css').freeze
  DEFAULT_SCOPE = 'default'.freeze

  # Any rule whose selectors mention .hljs, e.g.
  # "& .hljs-doctag,\n& .hljs-keyword {\n color: #c678dd;\n}"
  RULE = /([^{}]*\.hljs[^{}]*)\{([^{}]*)\}/m

  # A selector we can map to a single highlight.js scope. Deliberately excludes
  # compound and descendant selectors like ".hljs-title.class_" and
  # ".hljs-class .hljs-title" - they're contextual, and a token only carries its
  # own scope, so there's nothing to key them off. Skipping them leaves the
  # plain scope's colour in place, which is the common case.
  SIMPLE_SELECTOR = /\A\s*&\s*\.hljs([\w-]*)\s*\z/

  COLOUR = /(?:\A|[;{\s])color:\s*(#\h{3,8})/
  ITALIC = /font-style:\s*italic/
  BOLD = /font-weight:\s*bold/

  def call
    stripped_css.scan(RULE).each_with_object({}) do |(selectors, body), styles|
      style = style_for(body)
      next if style.empty?

      selectors.split(',').each do |selector|
        suffix = selector[SIMPLE_SELECTOR, 1]
        next if suffix.nil?

        styles[scope_for(suffix)] = style
      end
    end
  end

  private
  # Comments in the theme document the palette in hex, which would otherwise
  # look like declarations to the scanner.
  def stripped_css = CSS_PATH.read.gsub(%r{/\*.*?\*/}m, '')

  def scope_for(suffix)
    suffix = suffix.delete_prefix('-')
    suffix.presence || DEFAULT_SCOPE
  end

  def style_for(body)
    {
      colour: body[COLOUR, 1],
      italic: body.match?(ITALIC).presence,
      bold: body.match?(BOLD).presence
    }.compact
  end
end
