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
    rel_nofollow = '<p><a href="http://example.com" target="_blank" rel="nofollow">Some link</a></p>'

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

  test 'does not add target="blank" to internal link' do
    schemes = %w[https http]
    domains = %w[exercism.io exercism.lol local.exercism.io]

    schemes.product(domains).each do |scheme, domain|
      expected = %(<p><a href="#{scheme}://#{domain}/tracks/ruby">Some link</a></p>)
      assert_equal expected.chomp, Markdown::Parse.("[Some link](#{scheme}://#{domain}/tracks/ruby)").chomp
    end
  end

  test 'adds rel="noopener" to external links' do
    expected = '<p><a href="http://example.com" target="_blank" rel="noopener">Some link</a></p>'
    assert_equal expected.chomp, Markdown::Parse.('[Some link](http://example.com)').chomp
  end

  test 'does not add rel="noopener" to external links with no_follow' do
    expected = '<p><a href="http://example.com" target="_blank" rel="nofollow">Some link</a></p>'
    assert_equal expected.chomp, Markdown::Parse.('[Some link](http://example.com)', nofollow_links: true).chomp
  end

  test "parses double tildes as strikethrough" do
    assert_equal "<p><del>Hello</del></p>\n", Markdown::Parse.("~~Hello~~")
  end

  test "does not remove level one headings by default" do
    assert_equal "<h1>Top heading</h1>\n<p>Content</p>\n", Markdown::Parse.("# Top heading\n\nContent")
  end

  test "can remove level one headings" do
    assert_equal "<p>Content</p>\n", Markdown::Parse.("# Top heading\n\nContent", strip_h1: true)
  end

  test "does not remove level one headings in code blocks" do
    assert_equal "<pre><code class=\"language-ruby\"># Top heading\n</code></pre>\n",
      Markdown::Parse.("```ruby\n# Top heading\n```", strip_h1: true)
  end

  test "increment level of headings with greater than one" do
    assert_equal "<h3>Level two</h3>\n<h4>Level three</h4>\n", Markdown::Parse.("## Level two\n\n### Level three")
  end

  test "does not increment level of level one headings" do
    assert_equal "<h1>Level one</h1>\n", Markdown::Parse.("# Level one\n", strip_h1: false)
  end

  test "removes html comments" do
    assert_equal "\n<p>Regular text</p>\n", Markdown::Parse.("<!-- Comment text -->\n\nRegular text\n", strip_h1: false)
  end

  test "render internal concept link using absolute URL" do
    expected = %(<p><a href="https://exercism.io/tracks/ruby/concepts/basics" data-tooltip-type="concept" data-endpoint="/tracks/ruby/concepts/basics/tooltip">basics</a></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[basics](https://exercism.io/tracks/ruby/concepts/basics)")
  end

  test "render internal concept link using absolute path" do
    expected = %(<p><a href="/tracks/ruby/concepts/basics" data-tooltip-type="concept" data-endpoint="/tracks/ruby/concepts/basics/tooltip">basics</a></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[basics](/tracks/ruby/concepts/basics)")
  end

  test "render internal exercise link using absolute URL" do
    skip # TODO: enable one exercise tooltips are enabled
    expected = %(<p><a href="https://exercism.io/tracks/ruby/exercises/anagram" data-tooltip-type="exercise" data-endpoint="/tracks/ruby/exercises/anagram/tooltip">anagram</a></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[anagram](https://exercism.io/tracks/ruby/exercises/anagram)")
  end

  test "render internal exercise link using absolute path" do
    skip # TODO: enable one exercise tooltips are enabled
    expected = %(<p><a href="/tracks/ruby/exercises/anagram" data-tooltip-type="exercise" data-endpoint="/tracks/ruby/exercises/anagram/tooltip">anagram</a></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[anagram](/tracks/ruby/exercises/anagram)")
  end

  test "render internal link using exercism.io domain" do
    expected = %(<p><a href="https://exercism.io/tracks/ruby/concepts/basics" data-tooltip-type="concept" data-endpoint="/tracks/ruby/concepts/basics/tooltip">basics</a></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[basics](https://exercism.io/tracks/ruby/concepts/basics)")
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
    expected = %(<p><a href="https://exercism.io/tracks/ruby/concepts/basics/" data-tooltip-type="concept" data-endpoint="/tracks/ruby/concepts/basics/tooltip">basics</a></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[basics](https://exercism.io/tracks/ruby/concepts/basics/)")
  end

  test "render internal link without trailing slash" do
    expected = %(<p><a href="https://exercism.io/tracks/ruby/concepts/basics" data-tooltip-type="concept" data-endpoint="/tracks/ruby/concepts/basics/tooltip">basics</a></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[basics](https://exercism.io/tracks/ruby/concepts/basics)")
  end

  test "render internal link ending with hash" do
    expected = %(<p><a href="https://exercism.io/tracks/ruby/concepts/basics#intro" data-tooltip-type="concept" data-endpoint="/tracks/ruby/concepts/basics/tooltip">basics</a></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[basics](https://exercism.io/tracks/ruby/concepts/basics#intro)")
  end

  test "render internal link ending with question mark" do
    expected = %(<p><a href="https://exercism.io/tracks/ruby/concepts/basics?refresh" data-tooltip-type="concept" data-endpoint="/tracks/ruby/concepts/basics/tooltip">basics</a></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[basics](https://exercism.io/tracks/ruby/concepts/basics?refresh)")
  end

  test "render internal link with track containing special characters" do
    expected = %(<p><a href="https://exercism.io/tracks/common-lisp_2-%F0%9F%8E%99/concepts/basics/" data-tooltip-type="concept" data-endpoint="/tracks/common-lisp_2-%F0%9F%8E%99/concepts/basics/tooltip">basics</a></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[basics](https://exercism.io/tracks/common-lisp_2-🎙/concepts/basics/)")
  end

  test "render internal link with concept containing special characters" do
    expected = %(<p><a href="https://exercism.io/tracks/ruby/concepts/1_2-3_%F0%9F%8E%B8" data-tooltip-type="concept" data-endpoint="/tracks/ruby/concepts/1_2-3_%F0%9F%8E%B8/tooltip">123</a></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[123](https://exercism.io/tracks/ruby/concepts/1_2-3_🎸)")
  end

  test "render internal link with exercise containing special characters" do
    skip # TODO: enable one exercise tooltips are enabled
    expected = %(<p><a href="https://exercism.io/tracks/ruby/exercises/bank-%F0%9F%8E%B8" data-tooltip-type="concept" data-endpoint="/tracks/ruby/exercises/bank-%F0%9F%8E%B8/tooltip">bank</a></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[bank](https://exercism.io/tracks/ruby/exercises/bank-💰)")
  end

  test "skip unsupported internal links" do
    expected = %(<p><a href="https://exercism.io/tracks/ruby/contributors/iliketohelp">iliketohelp</a></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[iliketohelp](https://exercism.io/tracks/ruby/contributors/iliketohelp)")
  end

  test "render concept widget link without link" do
    skip # TODO: enable once we know how to handle widgets
    expected = %(<p><span data-react-widget="julia/concepts/if-statements\" class=\"data-react-concept-widget\"></span></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[concept:julia/if-statements]()")
  end

  test "render concept widget link with link" do
    skip # TODO: enable once we know how to handle widgets
    expected = %(<p><span data-react-widget="julia/concepts/if-statements\" class=\"data-react-concept-widget\"></span></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected,
      Markdown::Parse.("[concept:julia/if-statements](https://exercism.io/tracks/julia/concepts/if-statements)")
  end

  test "render exercise widget link without link" do
    skip # TODO: enable once we know how to handle widgets
    expected = %(<p><span data-react-widget="julia/exercises/two-fer\" class=\"data-react-exercise-widget\"></span></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[exercise:julia/two-fer]()")
  end

  test "render exercise widget link with link" do
    skip # TODO: enable once we know how to handle widgets
    expected = %(<p><span data-react-widget="julia/exercises/two-fer\" class=\"data-react-exercise-widget\"></span></p>\n) # rubocop:disable Layout/LineLength
    assert_equal expected, Markdown::Parse.("[exercise:julia/two-fer](https://exercism.io/tracks/julia/exercises/two-fer)")
  end
end
