require 'test_helper'

class ParseMarkdownTest < ActiveSupport::TestCase
  test "empty in is empty out" do
    assert_equal "", ParseMarkdown.("\n")
  end

  test "converts markdown to html" do
    expected = %q{<h1>OHAI</h1>
<p>So I was split between two ways of doing this.</p>
<ol>
<li>Either method pairs with adjectives (which I did),</li>
<li>Some sort of data structure (e.g. a hash might look like)</li>
</ol>
<p><a href="http://example.com" target="_blank">Some link</a></p>
<p>Watch this:</p>
<pre><code class="language-plain">$ go home
</code></pre>}

    actual = ParseMarkdown.(%q{
# OHAI

So I was split between two ways of doing this.

1. Either method pairs with adjectives (which I did),
2. Some sort of data structure (e.g. a hash might look like)

[Some link](http://example.com)

Watch this:

```
$ go home
```
})
    assert_equal expected.chomp, actual.chomp
  end

  test "sanitizes bad tags" do
    expected = %q{<p>Here is a sample of what a textarea block looks like:</p>
&lt;iframe&gt;&lt;/iframe&gt;
<p>Done</p>}

    actual = ParseMarkdown.(%q{
Here is a sample of what a textarea block looks like:

<iframe></iframe>

Done})
    assert_equal expected.chomp, actual.chomp
  end
  test "allows details" do
    expected = %q{<p>Here is a sample of what a details/summary block looks like:</p>
<details><summary>Click the little arrow to get a hint!</summary>
This is the spoiler that I want to show.</details>
<p>Done</p>}

    actual = ParseMarkdown.(%q{
Here is a sample of what a details/summary block looks like:

<details><summary>Click the little arrow to get a hint!</summary>
This is the spoiler that I want to show.</details>

Done})
    assert_equal expected.chomp, actual.chomp
  end

  test "doesn't blow up with nil" do
    assert_equal "", ParseMarkdown.(nil)
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
    assert_equal expected, ParseMarkdown.(table)
  end

  test "resepects rel_nofollow" do
    normal = %q{<p><a href="http://example.com" target="_blank">Some link</a></p>}
    rel_nofollow = %q{<p><a href="http://example.com" target="_blank" rel="nofollow">Some link</a></p>}

    assert_equal normal.chomp, ParseMarkdown.(%q{[Some link](http://example.com)}).chomp
    assert_equal rel_nofollow.chomp, ParseMarkdown.(%q{[Some link](http://example.com)}, nofollow_links: true).chomp
  end

  test "parses double tildes as strikethrough" do
    assert_equal "<p><del>Hello</del></p>\n", ParseMarkdown.("~~Hello~~")
  end
end
