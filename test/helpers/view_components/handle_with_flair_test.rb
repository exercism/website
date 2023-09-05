require "test_helper"

class ViewComponents::HandleWithFlairTest < ActionView::TestCase
  include IconsHelper
  include Propshaft::Helper

  test "nothing with no flair" do
    handle = "iHiD"

    expected = %(<span class="inline-flex items-center leading-150">#{handle}</span>)
    actual = render(ViewComponents::HandleWithFlair.new(handle, nil))
    assert_equal expected, actual
  end

  test "defaults are correct" do
    handle = "iHiD"
    flair = 'insider'
    title = 'An Exercism Insider'
    alt = "#{title}'s flair"

    expected = tag.span(class: 'inline-flex items-center leading-150') do
      safe_join([
        handle,
        image_tag('/assets/icons/insiders-d0418ec8b59d21a8852f7326404fa20b2d21785d.svg', alt:, class: 'c-icon',
          style: "all:unset; height: 13px; width: 13px; margin-left: 4px; margin-bottom: 1px", title:)
      ].compact)
    end

    actual = render(ViewComponents::HandleWithFlair.new(handle, flair))
    assert_equal expected, actual
  end

  test "size changes correctly" do
    actual = render(ViewComponents::HandleWithFlair.new('x', :insider, size: :large))
    assert_includes actual, "17px"
    refute_includes actual, "13px"
  end
end
