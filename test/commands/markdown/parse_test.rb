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
<p><a href="http://example.com" target="_blank" rel="noreferrer">Some link</a></p>
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

  test "sanitizes data- attributes" do
    expected = '<div>test</div>'

    actual = Markdown::Parse.('<div data-react-id="abd" data-react-data="{}" --hydrated>test</div>')
    assert_equal expected.chomp, actual.chomp
  end

  test "does not sanitize allowed attributes" do
    expected = '<div id="first" href="#" target="_blank" class="button" src="test.com" alt="lovely" width="80" height="50">test</div>'

    actual = Markdown::Parse.('<div id="first" href="#" target="_blank" class="button" src="test.com" alt="lovely" width="80" height="50">test</div>') # rubocop:disable Layout/LineLength
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
      <div class="c-responsive-table-wrapper">
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
      </div>
    HTML
    assert_equal expected, Markdown::Parse.(table)
  end

  test "respects rel_nofollow" do
    normal = '<p><a href="http://example.com" target="_blank" rel="noreferrer">Some link</a></p>'
    rel_nofollow = '<p><a href="http://example.com" target="_blank" rel="noreferrer nofollow">Some link</a></p>'

    assert_equal normal.chomp, Markdown::Parse.('[Some link](http://example.com)').chomp
    assert_equal rel_nofollow.chomp, Markdown::Parse.('[Some link](http://example.com)', nofollow_links: true).chomp
  end

  test 'adds target="blank" to external links' do
    expected = '<p><a href="http://example.com" target="_blank" rel="noreferrer">Some link</a></p>'
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

  test 'adds rel="noreferrer" to external links' do
    expected = '<p><a href="http://example.com" target="_blank" rel="noreferrer">Some link</a></p>'
    assert_equal expected.chomp, Markdown::Parse.('[Some link](http://example.com)').chomp
  end

  test 'does not add rel="noreferrer" to external links with no_follow' do
    expected = '<p><a href="http://example.com" target="_blank" rel="noreferrer nofollow">Some link</a></p>'
    assert_equal expected.chomp, Markdown::Parse.('[Some link](http://example.com)', nofollow_links: true).chomp
  end

  test 'adds data-turbo="false" to internal links with anchor' do
    expected = '<p><a href="https://exercism.org#h-about" data-turbo="false">Some link</a></p>'
    assert_equal expected.chomp, Markdown::Parse.('[Some link](https://exercism.org#about)').chomp
  end

  test 'does not add data-turbo="false" to internal links without anchor' do
    expected = '<p><a href="https://exercism.org">Some link</a></p>'
    assert_equal expected.chomp, Markdown::Parse.('[Some link](https://exercism.org)').chomp
  end

  test 'does not add data-turbo="false" to external links with anchor' do
    expected = '<p><a href="http://example.com#faq" target="_blank" rel="noreferrer">Some link</a></p>'
    assert_equal expected.chomp, Markdown::Parse.('[Some link](http://example.com#faq)').chomp
  end

  test "parses double tildes as strikethrough" do
    assert_equal "<p><del>Hello</del></p>\n", Markdown::Parse.("~~Hello~~")
  end

  test "removes level one headings by default" do
    assert_equal "<p>Content</p>\n", Markdown::Parse.("# Top heading\n\nContent")
  end

  test "can not remove level one headings" do
    assert_equal "<h2 id=\"h-top-heading\">Top heading</h2>\n<p>Content</p>\n",
      Markdown::Parse.("# Top heading\n\nContent", strip_h1: false)
  end

  test "does not remove level one headings in code blocks" do
    assert_equal "<pre><code class=\"language-ruby\"># Top heading\n</code></pre>\n",
      Markdown::Parse.("```ruby\n# Top heading\n```")
  end

  test "increment level of headings with greater than one" do
    assert_equal %(<h3 id="h-level-two">Level two</h3>\n<h4 id="h-level-three">Level three</h4>\n),
      Markdown::Parse.("## Level two\n\n### Level three")
  end

  test "does not lower headings beyond h6" do
    str = "#### Level four\n\n##### Level five\n\n###### Level six\n\n####### Level seven"
    assert_equal "<h5 id=\"h-level-four\">Level four</h5>\n<h6 id=\"h-level-five\">Level five</h6>\n<h6 id=\"h-level-six\">Level six</h6>\n<p>####### Level seven</p>\n", # rubocop:disable Layout/LineLength
      Markdown::Parse.(str)
  end

  test "does not increment level of level one heading if stripping" do
    assert_equal "", Markdown::Parse.("# Level one\n", strip_h1: true)
    assert_equal "<h2 id=\"h-level-one\">Level one</h2>\n", Markdown::Parse.("# Level one\n", strip_h1: false)
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
    expected = %(<p><a href="https://exercism.org/tracks/ruby/concepts/basics#h-intro" data-turbo="false" data-tooltip-type="concept" data-endpoint="/tracks/ruby/concepts/basics/tooltip">basics</a></p>\n) # rubocop:disable Layout/LineLength
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
    expected = %(<p><a href="https://exercism.org/tracks/ruby/contributors/iliketohelp">iliketohelp</a></p>\n)
    assert_equal expected, Markdown::Parse.("[iliketohelp](https://exercism.org/tracks/ruby/contributors/iliketohelp)")
  end

  test "render concept widget link without link" do
    expected = %(<p><a href="https://exercism.org/tracks/julia/concepts/if-statements" data-tooltip-type="concept" data-endpoint="/tracks/julia/concepts/if-statements/tooltip">if-statements</a></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[concept:julia/if-statements]()")
  end

  test "render concept widget link with link" do
    expected = %(<p><a href="https://exercism.org/tracks/julia/concepts/if-statements" data-tooltip-type="concept" data-endpoint="/tracks/julia/concepts/if-statements/tooltip">if-statements</a></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected,
      Markdown::Parse.("[concept:julia/if-statements](https://exercism.org/tracks/julia/concepts/if-statements)")
  end

  test "render exercise widget link without link" do
    expected = %(<p><a href="https://exercism.org/tracks/julia/exercises/two-fer" data-tooltip-type="exercise" data-endpoint="/tracks/julia/exercises/two-fer/tooltip">two-fer</a></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[exercise:julia/two-fer]()")
  end

  test "render exercise widget link with link" do
    expected = %(<p><a href="https://exercism.org/tracks/julia/exercises/two-fer" data-tooltip-type="exercise" data-endpoint="/tracks/julia/exercises/two-fer/tooltip">two-fer</a></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[exercise:julia/two-fer](https://exercism.org/tracks/julia/exercises/two-fer)")
  end

  test "render article widget link without link" do
    expected = %(<p><a href="https://exercism.org/tracks/julia/exercises/reverse-string/articles/performance">performance</a></p>\n)
    assert_equal expected, Markdown::Parse.("[article:julia/reverse-string/performance]()")
  end

  test "render article widget link with link" do
    expected = %(<p><a href="https://exercism.org/tracks/julia/exercises/reverse-string/articles/performance">performance</a></p>\n)
    assert_equal expected, Markdown::Parse.("[article:julia/reverse-string/performance](https://exercism.org/tracks/julia/exercises/reverse-string/articles/performance)")
  end

  test "render approach widget link without link" do
    expected = %(<p><a href="https://exercism.org/tracks/julia/exercises/two-fer/approaches/default-value">default-value</a></p>\n)
    assert_equal expected, Markdown::Parse.("[approach:julia/two-fer/default-value]()")
  end

  test "render approach widget link with link" do
    expected = %(<p><a href="https://exercism.org/tracks/julia/exercises/two-fer/approaches/default-value">default-value</a></p>\n)
    assert_equal expected, Markdown::Parse.("[approach:julia/two-fer/default-value](https://exercism.org/tracks/julia/exercises/two-fer/approaches/default-value)")
  end

  test "don't render exercise widget for approach link" do
    expected = %(<p><a href="https://exercism.org/tracks/julia/exercises/two-fer/approaches/default-value">approach</a></p>\n)
    assert_equal expected, Markdown::Parse.("[approach](https://exercism.org/tracks/julia/exercises/two-fer/approaches/default-value)")
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

  test "render vimeo video with fake id" do
    expected = %(<div style="padding:56.25% 0 0 0;position:relative;"><iframe src="https://player.vimeo.com/video/1234567890?badge=0&amp;autopause=0&amp;player_id=0&amp;app_id=58479" frameborder="0" allow="autoplay; fullscreen; picture-in-picture" allowfullscreen style="position:absolute;top:0;left:0;width:100%;height:100%;" title="X Exercism_ Tutorial Your first mentoring session 1.m4v"></iframe></div><script src="https://player.vimeo.com/api/player.js"></script>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[video:vimeo/1234567890]()")
  end

  test "render vimeo video with h= id" do
    expected = %(<div style="padding:56.25% 0 0 0;position:relative;"><iframe src="https://player.vimeo.com/video/906101866?h=2954ad331e&badge=0&amp;autopause=0&amp;player_id=0&amp;app_id=58479" frameborder="0" allow="autoplay; fullscreen; picture-in-picture" allowfullscreen style="position:absolute;top:0;left:0;width:100%;height:100%;" title="X Exercism_ Tutorial Your first mentoring session 1.m4v"></iframe></div><script src="https://player.vimeo.com/api/player.js"></script>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[video:vimeo/906101866?h=2954ad331e]()")
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

  ["", "/docs/", "/tracks/csharp/exercises/", "/tracks/csharp/concepts/"].each do |path|
    test "inline link for #{path} path with hash but not prefixed with 'h-'" do
      expected = %(<p><a href="#{path}#h-test" data-turbo="false">Link</a></p>\n)
      assert_equal expected, Markdown::Parse.("[Link](#{path}#test)")
    end

    test "inline link for #{path} path with hash but no domain prefixed with 'h-'" do
      expected = %(<p><a href="#{path}#h-test" data-turbo="false">Link</a></p>\n)
      assert_equal expected, Markdown::Parse.("[Link](#{path}#test)")
    end

    test "inline link for #{path} path with hash prefixed with 'h-' does not add another 'h-' prefix" do
      expected = %(<p><a href="#{path}#h-test" data-turbo="false">Link</a></p>\n)
      assert_equal expected, Markdown::Parse.("[Link](#{path}#h-test)")
    end

    %w[exercism.org exercism.io].each do |domain|
      test "inline link for #{path} path with hash and #{domain} domain prefixed with 'h-'" do
        expected = %(<p><a href=\"https://#{domain}#{path}#h-test\" data-turbo=\"false\">Link</a></p>\n)
        assert_equal expected, Markdown::Parse.("[Link](https://#{domain}#{path}#test)")
      end
    end
  end

  test "inline link with hash for non-special path not prefixed with 'h-'" do
    expected = %(<p><a href="https://exercism.org/about/#test" data-turbo="false">Link</a></p>\n)
    assert_equal expected, Markdown::Parse.("[Link](https://exercism.org/about/#test)")
  end

  test "inline link with hash and non-exercism domain not prefixed with 'h-'" do
    expected = %(<p><a href="https://test.org/docs/#test" target="_blank" rel="noreferrer">Link</a></p>\n)
    assert_equal expected, Markdown::Parse.("[Link](https://test.org/docs/#test)")
  end

  test "render youtube video for mail with link" do
    expected = %(<a href="https://www.youtube.com/watch?v=LknqlTouTKg" style="display:block; box-shadow: 0px 2px 4px #0F0923">\n<img src="https://assets.exercism.org/images/thumbnails/yt-jose-interview-preview.jpg" style="width:100%; display:block"/>\n</a>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[video:youtube-mail/LknqlTouTKg](https://assets.exercism.org/images/thumbnails/yt-jose-interview-preview.jpg)")
  end

  test "render youtube video for mail with link containing underscore" do
    expected = %(<a href="https://www.youtube.com/watch?v=GOPmj_AMbP8" style="display:block; box-shadow: 0px 2px 4px #0F0923">\n<img src="https://assets.exercism.org/images/thumbnails/yt-insiders-2023-07-31-with-play-icon.jpg" style="width:100%; display:block"/>\n</a>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[video:youtube-mail/GOPmj_AMbP8](https://assets.exercism.org/images/thumbnails/yt-insiders-2023-07-31-with-play-icon.jpg)")
  end

  test "render youtube video for mail with link containing dash" do
    expected = %(<a href="https://www.youtube.com/watch?v=mwe-9RIV39Y" style="display:block; box-shadow: 0px 2px 4px #0F0923">\n<img src="https://assets.exercism.org/images/thumbnails/yt-insiders-2023-07-31-with-play-icon.jpg" style="width:100%; display:block"/>\n</a>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[video:youtube-mail/mwe-9RIV39Y](https://assets.exercism.org/images/thumbnails/yt-insiders-2023-07-31-with-play-icon.jpg)")
  end

  %w[svg png jpg jpeg gif].each do |extension|
    test "render invertible images with .#{extension} using correct class" do
      expected = %(<p><img src="tic-tac-toe-invertible.#{extension}" alt="Tic Tac Toe board" class="c-img-invertible"></p>\n)
      assert_equal expected, Markdown::Parse.("![Tic Tac Toe board](tic-tac-toe-invertible.#{extension})")
    end

    test "render light image with .#{extension} when dark image is rendered" do
      # TODO: figure out how to retain alt text for both images
      expected = %(<p><img src="tic-tac-toe-light.#{extension}" alt="Tic Tac Toe board" class="c-img-light-theme"><img src="tic-tac-toe-dark.#{extension}" alt="Tic Tac Toe board" class="c-img-dark-theme"></p>\n) # rubocop:disable Layout/LineLength
      assert_equal expected, Markdown::Parse.("![Tic Tac Toe board](tic-tac-toe-dark.#{extension})")
    end

    test "render dark image with .#{extension} when light image is rendered" do
      expected = %(<p><img src="tic-tac-toe-light.#{extension}" alt="Tic Tac Toe board" class="c-img-light-theme"><img src="tic-tac-toe-dark.#{extension}" alt="Tic Tac Toe board" class="c-img-dark-theme"></p>\n) # rubocop:disable Layout/LineLength
      assert_equal expected, Markdown::Parse.("![Tic Tac Toe board](tic-tac-toe-light.#{extension})")
    end

    test "render light #{extension} image with query string in url" do
      expected = %(<p><img src="tic-light.#{extension}?raw=true" alt="Tic" class="c-img-light-theme"><img src="tic-dark.#{extension}?raw=true" alt="Tic" class="c-img-dark-theme"></p>\n) # rubocop:disable Layout/LineLength
      assert_equal expected, Markdown::Parse.("![Tic](tic-light.#{extension}?raw=true)")
    end

    test "render regular #{extension} image" do
      expected = %(<p><img src="tic-tac-toe.#{extension}" alt="Tic Tac Toe board"></p>\n)
      assert_equal expected, Markdown::Parse.("![Tic Tac Toe board](tic-tac-toe.#{extension})")
    end

    test "render regular #{extension} image with query string in url" do
      expected = %(<p><img src="tic.#{extension}?raw=true" alt="Tic"></p>\n)
      assert_equal expected, Markdown::Parse.("![Tic](tic.#{extension}?raw=true)")
    end
  end
end
