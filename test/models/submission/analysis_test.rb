require 'test_helper'

class Submission::AnalysisTest < ActiveSupport::TestCase
  test "ops_success?" do
    refute create(:submission_analysis, ops_status: 199).ops_success?
    assert create(:submission_analysis, ops_status: 200).ops_success?
    refute create(:submission_analysis, ops_status: 201).ops_success?
  end

  test "ops_errored?" do
    assert create(:submission_analysis, ops_status: 199).ops_errored?
    refute create(:submission_analysis, ops_status: 200).ops_errored?
    assert create(:submission_analysis, ops_status: 201).ops_errored?
  end

  test "feedback_html for single simple comments" do
    TestHelpers.use_website_copy_test_repo!

    comments = ["ruby.two-fer.incorrect_default_param"]
    analysis = create :submission_analysis, data: { comments: comments }

    expected = "<p>What could the default value of the parameter be set to in order to avoid having to use a conditional?</p>\n" # rubocop:disable Layout/LineLength
    assert_equal expected, analysis.feedback_html
  end

  test "feedback_html for single comment hash" do
    TestHelpers.use_website_copy_test_repo!

    comments = [{
      "comment" => "ruby.two-fer.string_interpolation",
      "params" => {
        "name_variable" => "iHiD"
      }
    }]
    analysis = create :submission_analysis, data: { comments: comments }

    # rubocop:disable Layout/LineLength
    expected = '<p>As well as string interpolation, another common way to create strings in Ruby is to use <a href="https://www.rubyguides.com/2012/01/ruby-string-formatting/" target="_blank">String#%</a> (perhaps read as "String format").
For example:</p>
<pre><code class="language-ruby">"One for %s, one for you" % iHiD"
</code></pre>
'
    # rubocop:enable Layout/LineLength
    assert_equal expected, analysis.feedback_html
  end

  test "feedback_html for mixed comments" do
    TestHelpers.use_website_copy_test_repo!

    comments = [
      "ruby.two-fer.incorrect_default_param",
      {

        "comment" => "ruby.two-fer.string_interpolation",
        "params" => {
          "name_variable" => "iHiD"
        }
      }
    ]
    analysis = create :submission_analysis, data: { comments: comments }

    # rubocop:disable Layout/LineLength
    expected = '<p>What could the default value of the parameter be set to in order to avoid having to use a conditional?</p>
<hr>
<p>As well as string interpolation, another common way to create strings in Ruby is to use <a href="https://www.rubyguides.com/2012/01/ruby-string-formatting/" target="_blank">String#%</a> (perhaps read as "String format").
For example:</p>
<pre><code class="language-ruby">"One for %s, one for you" % iHiD"
</code></pre>
'

    # rubocop:enable Layout/LineLength
    assert_equal expected, analysis.feedback_html
  end

  test "has_comments?" do
    refute create(:submission_analysis, data: { comments: nil }).has_comments?
    refute create(:submission_analysis, data: { comments: [] }).has_comments?
    assert create(:submission_analysis, data: { comments: ['foobar'] }).has_comments?
  end

  test "informative comments: none" do
    comments = ["ruby.two-fer.incorrect_default_param"]
    analysis = create :submission_analysis, data: { comments: comments }

    assert_equal 0, analysis.num_informative_comments
    refute analysis.has_informative_comments?
  end

  test "informative comments: one" do
    analysis = create :submission_analysis, data: { comments: [{
      "comment" => "ruby.two-fer.string_interpolation",
      "type": "informative"
    }] }

    assert_equal 1, analysis.num_informative_comments
    assert analysis.has_informative_comments?
  end

  test "celebratory comments: none" do
    comments = ["ruby.two-fer.incorrect_default_param"]
    analysis = create :submission_analysis, data: { comments: comments }

    assert_equal 0, analysis.num_celebratory_comments
    refute analysis.has_celebratory_comments?
  end

  test "celebratory comments: one" do
    analysis = create :submission_analysis, data: { comments: [{
      "comment" => "ruby.two-fer.string_interpolation",
      "type": "celebratory"
    }] }

    assert_equal 1, analysis.num_celebratory_comments
    assert analysis.has_celebratory_comments?
  end

  test "essential comments: none" do
    comments = ["ruby.two-fer.incorrect_default_param"]
    analysis = create :submission_analysis, data: { comments: comments }

    assert_equal 0, analysis.num_essential_comments
    refute analysis.has_essential_comments?
  end

  test "essential comments: one" do
    analysis = create :submission_analysis, data: { comments: [{
      "comment" => "ruby.two-fer.string_interpolation",
      "type": "essential"
    }] }

    assert_equal 1, analysis.num_essential_comments
    assert analysis.has_essential_comments?
  end

  test "actionable comments: none" do
    analysis = create :submission_analysis, data: { comments: [] }

    assert_equal 0, analysis.num_actionable_comments
    refute analysis.has_actionable_comments?
  end

  test "actionable comments: short-syntax" do
    comments = ["ruby.two-fer.incorrect_default_param"]
    analysis = create :submission_analysis, data: { comments: comments }

    assert_equal 1, analysis.num_actionable_comments
    assert analysis.has_actionable_comments?
  end

  test "actionable comments: long-syntax" do
    analysis = create :submission_analysis, data: { comments: [{
      "comment" => "ruby.two-fer.string_interpolation",
      "type": "actionable"
    }] }

    assert_equal 1, analysis.num_actionable_comments
    assert analysis.has_actionable_comments?
  end

  # TODO: - Add a test for if the data is empty
end
