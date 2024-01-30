class Markdown::Parse
  include Mandate

  # TODO: (Optional) This needs fixing in mandate but I don't know
  # how to do it without breaking hashes passed as the
  # last argument
  def self.call(*args, **kwargs)
    new(*args, **kwargs).()
  end

  initialize_with :text, nofollow_links: false, strip_h1: true, lower_heading_levels_by: 1, heading_ids: true

  def call
    return "" if text.blank?

    sanitized_html
  end

  private
  memoize
  def sanitized_html
    remove_comments = Loofah::Scrubber.new do |node|
      node.remove if node.name == "comment"
    end

    remove_data_attributes = Loofah::Scrubber.new do |node|
      node.attribute_nodes.each do |attr_node|
        next if ALLOWED_ATTRIBUTE_NAMES.include?(attr_node.node_name)
        next if attr_node.node_name == 'data-tooltip-type' && ALLOWED_TOOLTIP_TYPES.include?(attr_node.value)
        next if attr_node.node_name == 'data-endpoint' && attr_node.value.start_with?('/')
        next if attr_node.node_name == 'data-turbo'

        attr_node.remove
      end
    end

    # rubocop:disable Style/MultilineBlockChain
    Loofah.fragment(raw_html).
      scrub!(remove_comments).
      scrub!(remove_data_attributes).
      scrub!(:escape).
      to_s.
      gsub(%r{<p><a href="https://player\.vimeo\.com/video/(\d+\?h=[0-9a-z]+)"[^>]*?>[^<]+</a></p>}) do
        %(<div style="padding:56.25% 0 0 0;position:relative;"><iframe src="https://player.vimeo.com/video/#{Regexp.last_match(1)}&badge=0&amp;autopause=0&amp;player_id=0&amp;app_id=58479" frameborder="0" allow="autoplay; fullscreen; picture-in-picture" allowfullscreen style="position:absolute;top:0;left:0;width:100%;height:100%;" title="X Exercism_ Tutorial Your first mentoring session 1.m4v"></iframe></div><script src="https://player.vimeo.com/api/player.js"></script>) # rubocop:disable Layout/LineLength
      end.
      gsub(%r{<p><a href="https://player\.vimeo\.com/video/(\d+)"[^>]*?>[^<]+</a></p>}) do
        %(<div style="padding:56.25% 0 0 0;position:relative;"><iframe src="https://player.vimeo.com/video/#{Regexp.last_match(1)}?badge=0&amp;autopause=0&amp;player_id=0&amp;app_id=58479" frameborder="0" allow="autoplay; fullscreen; picture-in-picture" allowfullscreen style="position:absolute;top:0;left:0;width:100%;height:100%;" title="X Exercism_ Tutorial Your first mentoring session 1.m4v"></iframe></div><script src="https://player.vimeo.com/api/player.js"></script>) # rubocop:disable Layout/LineLength
      end.
      gsub(%r{<p><a href="https://www\.youtube\.com/watch\?v=([\w-]+)"[^>]*?>([^<]+)</a></p>}) do
        %(<a href="https://www.youtube.com/watch?v=#{Regexp.last_match(1)}" style="display:block; box-shadow: 0px 2px 4px #0F0923">\n<img src="#{Regexp.last_match(2)}" style="width:100%; display:block"/>\n</a>) # rubocop:disable Layout/LineLength
      end
    # rubocop:enable Style/MultilineBlockChain
  end

  memoize
  def raw_html
    doc = Markdown::Render.(text, :doc, strip_h1:, lower_heading_levels_by:)
    Markdown::RenderHTML.(doc, nofollow_links:, heading_ids:)
  end

  ALLOWED_ATTRIBUTE_NAMES = %w[id href target rel class style width height alt src].freeze
  ALLOWED_TOOLTIP_TYPES = %w[concept exercise].freeze
  private_constant :ALLOWED_ATTRIBUTE_NAMES, :ALLOWED_TOOLTIP_TYPES
end
