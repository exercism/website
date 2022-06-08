class Markdown::Parse
  include Mandate

  # TODO: (Optional) This needs fixing in mandate but I don't know
  # how to do it without breaking hashes passed as the
  # last argument
  def self.call(*args, **kwargs)
    new(*args, **kwargs).()
  end

  def initialize(text, nofollow_links: false, strip_h1: true, lower_heading_levels_by: 1, heading_ids: false)
    @text = text
    @nofollow_links = nofollow_links
    @strip_h1 = strip_h1
    @lower_heading_levels_by = lower_heading_levels_by
    @heading_ids = heading_ids
  end

  def call
    return "" if text.blank?

    sanitized_html
  end

  private
  attr_reader :text, :nofollow_links, :strip_h1, :lower_heading_levels_by, :heading_ids

  memoize
  def sanitized_html
    remove_comments = Loofah::Scrubber.new do |node|
      node.remove if node.name == "comment"
    end

    Loofah.fragment(raw_html).
      scrub!(remove_comments).
      scrub!(:escape).
      to_s.
      gsub(%r{<p><a href="https://player\.vimeo\.com/video/(595884893|595885125|595884449)"[^>]*?>[^<]+</a></p>}) do |_m|
        %(<div style="padding:56.25% 0 0 0;position:relative;"><iframe src="https://player.vimeo.com/video/#{$LAST_MATCH_INFO[1]}?badge=0&amp;autopause=0&amp;player_id=0&amp;app_id=58479" frameborder="0" allow="autoplay; fullscreen; picture-in-picture" allowfullscreen style="position:absolute;top:0;left:0;width:100%;height:100%;" title="X Exercism_ Tutorial Your first mentoring session 1.m4v"></iframe></div><script src="https://player.vimeo.com/api/player.js"></script>) # rubocop:disable Layout/LineLength
      end
  end

  memoize
  def raw_html
    doc = Markdown::Render.(text, :doc, strip_h1:, lower_heading_levels_by:)
    Markdown::RenderHTML.(doc, nofollow_links:, heading_ids:)
  end
end
