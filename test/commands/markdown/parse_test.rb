require 'test_helper'

class Markdown::ParseTest < ActiveSupport::TestCase
  test "empty in is empty out" do
    assert_equal "", Markdown::Parse.("\n")
  end

  test "converts markdown to html" do
    expected = '<p>So I was split between two ways of doing this.</p>
<ol>
<li>Either method pairs with adjectives (which I did),</li>
<li>Some sort of data structure (e.g. a hash might look like)</li>
</ol>
<p><a href="http://example.com" target="_blank" rel="noopener">Some link</a></p>
<p>Watch this:</p>
<pre><code class="language-plain">$ go home
</code></pre>'

    actual = Markdown::Parse.('
So I was split between two ways of doing this.

1. Either method pairs with adjectives (which I did),
2. Some sort of data structure (e.g. a hash might look like)

[Some link](http://example.com)

Watch this:

```
$ go home
```
')
    assert_equal expected.chomp, actual.chomp
  end

  test "sanitizes bad tags" do
    expected = '<p>Here is a sample of what a textarea block looks like:</p>
&lt;iframe&gt;&lt;/iframe&gt;
<p>Done</p>'

    actual = Markdown::Parse.('
Here is a sample of what a textarea block looks like:

<iframe></iframe>

Done')
    assert_equal expected.chomp, actual.chomp
  end

  test "allows details" do
    expected = '<p>Here is a sample of what a details/summary block looks like:</p>
<details><summary>Click the little arrow to get a hint!</summary>
This is the spoiler that I want to show.</details>
<p>Done</p>'

    actual = Markdown::Parse.('
Here is a sample of what a details/summary block looks like:

<details><summary>Click the little arrow to get a hint!</summary>
This is the spoiler that I want to show.</details>

Done')
    assert_equal expected.chomp, actual.chomp
  end

  test "doesn't blow up with nil" do
    assert_equal "", Markdown::Parse.(nil)
  end

  test "parses tables" do
    table = <<~TABLE
      1   | 2
      --- | ---
      3   | 4
    TABLE

    expected = <<~HTML
      <table>
      <thead>
      <tr>
      <th>1</th>
      <th>2</th>
      </tr>
      </thead>
      <tbody>
      <tr>
      <td>3</td>
      <td>4</td>
      </tr>
      </tbody>
      </table>
    HTML
    assert_equal expected, Markdown::Parse.(table)
  end

  test "respects rel_nofollow" do
    normal = '<p><a href="http://example.com" target="_blank" rel="noopener">Some link</a></p>'
    rel_nofollow = '<p><a href="http://example.com" target="_blank" rel="noopener nofollow">Some link</a></p>'

    assert_equal normal.chomp, Markdown::Parse.('[Some link](http://example.com)').chomp
    assert_equal rel_nofollow.chomp, Markdown::Parse.('[Some link](http://example.com)', nofollow_links: true).chomp
  end

  test 'adds target="blank" to external links' do
    expected = '<p><a href="http://example.com" target="_blank" rel="noopener">Some link</a></p>'
    assert_equal expected.chomp, Markdown::Parse.('[Some link](http://example.com)').chomp
  end

  test 'does not add target="blank" to relative link' do
    expected = '<p><a href="./link/to/page">Some link</a></p>'
    assert_equal expected.chomp, Markdown::Parse.('[Some link](./link/to/page)').chomp
  end

  test 'does not add target="blank" to parent relative link' do
    expected = '<p><a href="../link/to/page">Some link</a></p>'
    assert_equal expected.chomp, Markdown::Parse.('[Some link](../link/to/page)').chomp
  end

  test 'does not add target="blank" to absolute link' do
    expected = '<p><a href="/link/to/page">Some link</a></p>'
    assert_equal expected.chomp, Markdown::Parse.('[Some link](/link/to/page)').chomp
  end

  schemes = %w[https http]
  domains = %w[exercism.io exercism.lol local.exercism.io exercism.org]

  schemes.product(domains).each do |scheme, domain|
    test "does not add target=\"blank\" to internal link on #{scheme}://#{domain}" do
      expected = %(<p><a href="#{scheme}://#{domain}/tracks/ruby">Some link</a></p>)
      assert_equal expected.chomp, Markdown::Parse.("[Some link](#{scheme}://#{domain}/tracks/ruby)").chomp
    end
  end

  test 'adds rel="noopener" to external links' do
    expected = '<p><a href="http://example.com" target="_blank" rel="noopener">Some link</a></p>'
    assert_equal expected.chomp, Markdown::Parse.('[Some link](http://example.com)').chomp
  end

  test 'does not add rel="noopener" to external links with no_follow' do
    expected = '<p><a href="http://example.com" target="_blank" rel="noopener nofollow">Some link</a></p>'
    assert_equal expected.chomp, Markdown::Parse.('[Some link](http://example.com)', nofollow_links: true).chomp
  end

  test "parses double tildes as strikethrough" do
    assert_equal "<p><del>Hello</del></p>\n", Markdown::Parse.("~~Hello~~")
  end

  test "removes level one headings by default" do
    assert_equal "<p>Content</p>\n", Markdown::Parse.("# Top heading\n\nContent")
  end

  test "can not remove level one headings" do
    assert_equal "<h2>Top heading</h2>\n<p>Content</p>\n", Markdown::Parse.("# Top heading\n\nContent", strip_h1: false)
  end

  test "does not remove level one headings in code blocks" do
    assert_equal "<pre><code class=\"language-ruby\"># Top heading\n</code></pre>\n",
      Markdown::Parse.("```ruby\n# Top heading\n```")
  end

  test "increment level of headings with greater than one" do
    assert_equal "<h3>Level two</h3>\n<h4>Level three</h4>\n", Markdown::Parse.("## Level two\n\n### Level three")
  end

  test "does not lower headings beyond h6" do
    str = "#### Level four\n\n##### Level five\n\n###### Level six\n\n####### Level seven"
    assert_equal "<h5>Level four</h5>\n<h6>Level five</h6>\n<h6>Level six</h6>\n<p>####### Level seven</p>\n", Markdown::Parse.(str)
  end

  test "does not increment level of level one heading if stripping" do
    assert_equal "", Markdown::Parse.("# Level one\n", strip_h1: true)
    assert_equal "<h2>Level one</h2>\n", Markdown::Parse.("# Level one\n", strip_h1: false)
  end

  test "removes html comments" do
    assert_equal "\n<p>Regular text</p>\n", Markdown::Parse.("<!-- Comment text -->\n\nRegular text\n", strip_h1: false)
  end

  test "render internal concept link using absolute URL" do
    expected = %(<p><a href="https://exercism.org/tracks/ruby/concepts/basics" data-tooltip-type="concept" data-endpoint="/tracks/ruby/concepts/basics/tooltip">basics</a></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[basics](https://exercism.org/tracks/ruby/concepts/basics)")
  end

  test "render internal concept link using absolute path" do
    expected = %(<p><a href="/tracks/ruby/concepts/basics" data-tooltip-type="concept" data-endpoint="/tracks/ruby/concepts/basics/tooltip">basics</a></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[basics](/tracks/ruby/concepts/basics)")
  end

  test "render internal exercise link using absolute URL" do
    skip # TODO: enable one exercise tooltips are enabled
    expected = %(<p><a href="https://exercism.org/tracks/ruby/exercises/anagram" data-tooltip-type="exercise" data-endpoint="/tracks/ruby/exercises/anagram/tooltip">anagram</a></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[anagram](https://exercism.org/tracks/ruby/exercises/anagram)")
  end

  test "render internal exercise link using absolute path" do
    skip # TODO: enable one exercise tooltips are enabled
    expected = %(<p><a href="/tracks/ruby/exercises/anagram" data-tooltip-type="exercise" data-endpoint="/tracks/ruby/exercises/anagram/tooltip">anagram</a></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[anagram](/tracks/ruby/exercises/anagram)")
  end

  test "render internal link using exercism.org domain" do
    expected = %(<p><a href="https://exercism.org/tracks/ruby/concepts/basics" data-tooltip-type="concept" data-endpoint="/tracks/ruby/concepts/basics/tooltip">basics</a></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[basics](https://exercism.org/tracks/ruby/concepts/basics)")
  end

  test "render internal link using exercism.lol domain" do
    expected = %(<p><a href="https://exercism.lol/tracks/ruby/concepts/basics" data-tooltip-type="concept" data-endpoint="/tracks/ruby/concepts/basics/tooltip">basics</a></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[basics](https://exercism.lol/tracks/ruby/concepts/basics)")
  end

  test "render internal link using local.exercism.io domain" do
    expected = %(<p><a href="http://local.exercism.io/tracks/ruby/concepts/basics" data-tooltip-type="concept" data-endpoint="/tracks/ruby/concepts/basics/tooltip">basics</a></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[basics](http://local.exercism.io/tracks/ruby/concepts/basics)")
  end

  test "render internal link with trailing slash" do
    expected = %(<p><a href="https://exercism.org/tracks/ruby/concepts/basics/" data-tooltip-type="concept" data-endpoint="/tracks/ruby/concepts/basics/tooltip">basics</a></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[basics](https://exercism.org/tracks/ruby/concepts/basics/)")
  end

  test "render internal link without trailing slash" do
    expected = %(<p><a href="https://exercism.org/tracks/ruby/concepts/basics" data-tooltip-type="concept" data-endpoint="/tracks/ruby/concepts/basics/tooltip">basics</a></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[basics](https://exercism.org/tracks/ruby/concepts/basics)")
  end

  test "render internal link ending with hash" do
    expected = %(<p><a href="https://exercism.org/tracks/ruby/concepts/basics#intro" data-tooltip-type="concept" data-endpoint="/tracks/ruby/concepts/basics/tooltip">basics</a></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[basics](https://exercism.org/tracks/ruby/concepts/basics#intro)")
  end

  test "render internal link ending with question mark" do
    expected = %(<p><a href="https://exercism.org/tracks/ruby/concepts/basics?refresh" data-tooltip-type="concept" data-endpoint="/tracks/ruby/concepts/basics/tooltip">basics</a></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[basics](https://exercism.org/tracks/ruby/concepts/basics?refresh)")
  end

  test "render internal link with track containing special characters" do
    expected = %(<p><a href="https://exercism.org/tracks/common-lisp_2-%F0%9F%8E%99/concepts/basics/" data-tooltip-type="concept" data-endpoint="/tracks/common-lisp_2-%F0%9F%8E%99/concepts/basics/tooltip">basics</a></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[basics](https://exercism.org/tracks/common-lisp_2-🎙/concepts/basics/)")
  end

  test "render internal link with concept containing special characters" do
    expected = %(<p><a href="https://exercism.org/tracks/ruby/concepts/1_2-3_%F0%9F%8E%B8" data-tooltip-type="concept" data-endpoint="/tracks/ruby/concepts/1_2-3_%F0%9F%8E%B8/tooltip">123</a></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[123](https://exercism.org/tracks/ruby/concepts/1_2-3_🎸)")
  end

  test "render internal link with exercise containing special characters" do
    expected = %(<p><a href="https://exercism.org/tracks/ruby/exercises/bank-%F0%9F%92%B0" data-tooltip-type="exercise" data-endpoint="/tracks/ruby/exercises/bank-%F0%9F%92%B0/tooltip">bank</a></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[bank](https://exercism.org/tracks/ruby/exercises/bank-💰)")
  end

  test "skip unsupported internal links" do
    expected = %(<p><a href="https://exercism.org/tracks/ruby/contributors/iliketohelp">iliketohelp</a></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[iliketohelp](https://exercism.org/tracks/ruby/contributors/iliketohelp)")
  end

  test "render concept widget link without link" do
    # TODO: render concept widget instead of link
    expected = %(<p><a href="https://exercism.org/tracks/julia/concepts/if-statements" data-tooltip-type="concept" data-endpoint="/tracks/julia/concepts/if-statements/tooltip">if-statements</a></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[concept:julia/if-statements]()")
  end

  test "render concept widget link with link" do
    # TODO: render concept widget instead of link
    expected = %(<p><a href="https://exercism.org/tracks/julia/concepts/if-statements" data-tooltip-type="concept" data-endpoint="/tracks/julia/concepts/if-statements/tooltip">if-statements</a></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected,
      Markdown::Parse.("[concept:julia/if-statements](https://exercism.org/tracks/julia/concepts/if-statements)")
  end

  test "render exercise widget link without link" do
    # TODO: render exercise widget instead of link
    expected = %(<p><a href="https://exercism.org/tracks/julia/exercises/two-fer" data-tooltip-type="exercise" data-endpoint="/tracks/julia/exercises/two-fer/tooltip">two-fer</a></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[exercise:julia/two-fer]()")
  end

  test "render exercise widget link with link" do
    # TODO: render exercise widget instead of link
    expected = %(<p><a href="https://exercism.org/tracks/julia/exercises/two-fer" data-tooltip-type="exercise" data-endpoint="/tracks/julia/exercises/two-fer/tooltip">two-fer</a></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[exercise:julia/two-fer](https://exercism.org/tracks/julia/exercises/two-fer)")
  end

  test "copes with a bad link uri scheme" do
    # TODO: render exercise widget instead of link
    expected = %(<p><a href=\"https://exercism.org/tracks/julia/exercises/two-fer\" data-tooltip-type=\"exercise\" data-endpoint=\"/tracks/julia/exercises/two-fer/tooltip\">two-fer</a></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[exercise:julia/two-fer](+https://exercism.org/tracks/julia/exercises/two-fer)")
  end

  test "render vimeo video without link" do
    expected = %(<div style="padding:56.25% 0 0 0;position:relative;"><iframe src="https://player.vimeo.com/video/595885125?badge=0&amp;autopause=0&amp;player_id=0&amp;app_id=58479" frameborder="0" allow="autoplay; fullscreen; picture-in-picture" allowfullscreen style="position:absolute;top:0;left:0;width:100%;height:100%;" title="X Exercism_ Tutorial Your first mentoring session 1.m4v"></iframe></div><script src="https://player.vimeo.com/api/player.js"></script>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[video:vimeo/595885125]()")
  end

  test "render vimeo video with link" do
    expected = %(<div style="padding:56.25% 0 0 0;position:relative;"><iframe src="https://player.vimeo.com/video/595885125?badge=0&amp;autopause=0&amp;player_id=0&amp;app_id=58479" frameborder="0" allow="autoplay; fullscreen; picture-in-picture" allowfullscreen style="position:absolute;top:0;left:0;width:100%;height:100%;" title="X Exercism_ Tutorial Your first mentoring session 1.m4v"></iframe></div><script src="https://player.vimeo.com/api/player.js"></script>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[video:vimeo/595885125](https://player.vimeo.com/video/595885125)")
  end

  test "render note code block" do
    expected = %(<div class="c-textblock-note">\n<div class="c-textblock-header">Note</div>\n<div class="c-textblock-content">\n<p>Note this</p>\n</div>\n</div>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("```exercism/note\nNote this\n```")
    assert_equal expected, Markdown::Parse.("`````exercism/note\nNote this\n`````")
    assert_equal expected, Markdown::Parse.("~~~~~exercism/note\nNote this\n~~~~~")
  end

  test "render caution code block" do
    expected = %(<div class="c-textblock-caution">\n<div class="c-textblock-header">Caution</div>\n<div class="c-textblock-content">\n<p>Here be dragons</p>\n</div>\n</div>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("```exercism/caution\nHere be dragons\n```")
    assert_equal expected, Markdown::Parse.("`````exercism/caution\nHere be dragons\n`````")
    assert_equal expected, Markdown::Parse.("~~~~~exercism/caution\nHere be dragons\n~~~~~")
  end

  test "render advanced code block" do
    expected = %(<div class="c-textblock-advanced">\n<div class="c-textblock-header">Advanced</div>\n<div class="c-textblock-content">\n<p>Pointer arithmetic</p>\n</div>\n</div>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("```exercism/advanced\nPointer arithmetic\n```")
    assert_equal expected, Markdown::Parse.("`````exercism/advanced\nPointer arithmetic\n`````")
    assert_equal expected, Markdown::Parse.("~~~~~exercism/advanced\nPointer arithmetic\n~~~~~")
  end

  test "render note block with markdown note" do
    expected = %(<div class="c-textblock-note">\n<div class="c-textblock-header">Note</div>\n<div class="c-textblock-content">\n<p>There is <strong>markdown</strong> within <em>these</em> notes.</p>\n</div>\n</div>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("```exercism/note\nThere is **markdown** within _these_ notes.\n```")
    assert_equal expected, Markdown::Parse.("`````exercism/note\nThere is **markdown** within _these_ notes.\n`````")
    assert_equal expected, Markdown::Parse.("~~~~~exercism/note\nThere is **markdown** within _these_ notes.\n~~~~~")
  end

  test "render footnote" do
    expected = %(<p>Hello<sup class=\"footnote-ref\"><a href=\"#fn1\" id=\"fnref1\">1</a></sup>.</p>\n<section class=\"footnotes\">\n<ol>\n<li id=\"fn1\">\n<p>Hey! <a href=\"#fnref1\" class=\"footnote-backref\">↩</a></p>\n</li>\n</ol>\n</section>\n) # rubocop:disable Layout/LineLength
    assert_equal expected,
      Markdown::Parse.("Hello[^hi].\n\n[^hi]: Hey!\n")
  end

  test "heading id for lowercase letters title" do
    expected = %(<h2 id="h-lowerletters">lowerletters</h2>\n)
    assert_equal expected, Markdown::Parse.("## lowerletters", heading_ids: true, lower_heading_levels_by: 0)
  end

  test "heading id for uppercase letters title is converted to lowercase" do
    expected = %(<h2 id="h-upperletters">UPPERLETTERS</h2>\n)
    assert_equal expected, Markdown::Parse.("## UPPERLETTERS", heading_ids: true, lower_heading_levels_by: 0)
  end

  test "heading id for mixed-case letters title is converted to lowercase" do
    expected = %(<h2 id="h-pascalcase">PascalCase</h2>\n)
    assert_equal expected, Markdown::Parse.("## PascalCase", heading_ids: true, lower_heading_levels_by: 0)
  end

  test "heading id for diacritic letters title are converted to regular letters or dashes" do
    expected = %(<h2 id="h-o-a-eeee">Òǒốáȧëèéê</h2>\n)
    assert_equal expected, Markdown::Parse.("## Òǒốáȧëèéê", heading_ids: true, lower_heading_levels_by: 0)
  end

  test "heading id for numbers title" do
    expected = %(<h2 id="h-123456">123456</h2>\n)
    assert_equal expected, Markdown::Parse.("## 123456", heading_ids: true, lower_heading_levels_by: 0)
  end

  test "heading id with non-letter/digit characters title are replaced with dashes" do
    expected = %(<h2 id="h-this-is-m">this is m*</h2>\n)
    assert_equal expected, Markdown::Parse.("## this is m*", heading_ids: true, lower_heading_levels_by: 0)
  end

  test "heading id for code fence title" do
    expected = %(<h2 id="h-summary"><code>summary</code></h2>\n)
    assert_equal expected, Markdown::Parse.("## `summary`", heading_ids: true, lower_heading_levels_by: 0)
  end

  test "heading id for markdown title" do
    expected = %(<h2 id="h-why-is-it-not-e-g-must">Why is it not ... (e.g. <strong>MUST</strong>)?</h2>\n)
    assert_equal expected, Markdown::Parse.("## Why is it not ... (e.g. **MUST**)?", heading_ids: true, lower_heading_levels_by: 0)
  end

  test "heading id with consecutive non-letter/digit characters title are replaced with dashes" do
    expected = %(<h2 id="h-this-is-m">this % is @@ m</h2>\n)
    assert_equal expected, Markdown::Parse.("## this % is @@ m", heading_ids: true, lower_heading_levels_by: 0)
  end

  test "heading ids support all heading levels" do
    expected = %(<h1 id="h-one">one</h1>\n<h2 id="h-two">two</h2>\n<h3 id="h-three">three</h3>\n<h4 id="h-four">four</h4>\n<h5 id="h-five">five</h5>\n<h6 id="h-six">six</h6>\n) # rubocop:disable Layout/LineLength
    assert_equal expected,
      Markdown::Parse.("# one\n\n## two\n\n### three\n\n#### four\n\n##### five\n\n###### six", heading_ids: true,
        lower_heading_levels_by: 0, strip_h1: false)
  end

  test "heading id for same titles uses sequential numbering" do
    expected = %(<h2 id="h-my-title">my title</h2>\n<h2 id="h-my-title-1">my title</h2>\n<h2 id="h-my-title-2">my title</h2>\n)
    assert_equal expected, Markdown::Parse.("## my title\n\n## my title\n\n## my title", heading_ids: true, lower_heading_levels_by: 0)
  end
end
