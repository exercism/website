require 'test_helper'

class SerializeHighlightjsThemeTest < ActiveSupport::TestCase
  test "extracts colours for the scopes highlight.js emits" do
    theme = SerializeHighlightjsTheme.()

    # A representative spread rather than the full set, so restyling the theme
    # doesn't fail the suite for no reason.
    %w[default comment keyword string number title literal].each do |scope|
      assert theme.key?(scope), "expected a style for hljs-#{scope}"
      assert_match(/\A#\h{3,8}\z/, theme[scope][:colour], "expected a hex colour for hljs-#{scope}")
    end
  end

  test "reads scopes that share a rule with a compound or descendant selector" do
    theme = SerializeHighlightjsTheme.()

    # hljs-built_in is grouped with ".hljs-title.class_" and
    # ".hljs-class .hljs-title". An earlier version required every selector in
    # the group to be simple, so the whole rule - and built_in with it - was
    # dropped.
    assert_equal '#e6c07b', theme['built_in'][:colour]
  end

  test "skips contextual selectors that don't map to a single scope" do
    theme = SerializeHighlightjsTheme.()

    # "hljs-class" only ever appears as the ancestor in
    # ".hljs-class .hljs-title". A token carries its own scope and no context,
    # so there's nothing to match it on.
    refute theme.key?('class')
  end

  test "carries font-style and font-weight where the theme sets them" do
    theme = SerializeHighlightjsTheme.()

    assert theme['comment'][:italic], "comments are italic in the theme"
    assert theme['emphasis'][:italic], "emphasis is italic in the theme"
    assert theme['strong'][:bold], "strong is bold in the theme"
    refute theme['keyword'].key?(:bold), "keywords aren't bold in the theme"
  end

  test "shares one style across a grouped selector" do
    theme = SerializeHighlightjsTheme.()

    # "& .hljs-doctag, & .hljs-keyword, & .hljs-formula" is a single rule
    assert_equal theme['doctag'], theme['keyword']
    assert_equal theme['formula'], theme['keyword']
  end

  test "ignores the hex values in the palette comment" do
    theme = SerializeHighlightjsTheme.()

    # The theme opens with a comment listing "base: #282c34" and friends. If
    # those leaked in we'd get scopes that highlight.js never emits.
    assert(theme.keys.all? { |scope| scope.match?(/\A[\w-]+\z/) })
    refute theme.key?('base')
  end
end
