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

  test "summary returns data" do
    summary = "foobar"
    analysis = create :submission_analysis, data: { summary: }
    assert_equal summary, analysis.summary
  end

  test "summary is nil if empty" do
    analysis = create :submission_analysis, data: { summary: "" }
    assert_nil analysis.summary
  end

  test "tags is empty if nil" do
    analysis = create :submission_analysis, tags_data: { tags: nil }
    assert_empty analysis.tags
  end

  test "tags returns tags from tags_data" do
    tags = ["construct:if", "paradigm:functional"]
    analysis = create :submission_analysis, tags_data: { tags: }
    assert_equal tags, analysis.tags
  end

  test "comments doesn't raise" do
    TestHelpers.use_website_copy_test_repo!
    Github::Issue::Open.expects(:call)

    comments = ["ruby.two-fer.incorrect_default_param"]
    analysis = create :submission_analysis, data: { comments: }

    Markdown::Parse.expects(:call).raises
    expected = []
    assert_equal expected, analysis.comments
  end

  test "comments for single simple comments" do
    TestHelpers.use_website_copy_test_repo!

    comments = ["ruby.two-fer.incorrect_default_param"]
    analysis = create :submission_analysis, data: { comments: }

    expected = [{
      type: :informative,
      html: "<p>What could the default value of the parameter be set to in order to avoid having to use a conditional?</p>\n"
    }]
    assert_equal expected, analysis.comments
  end

  test "comments for single comment hash" do
    TestHelpers.use_website_copy_test_repo!

    comments = [{
      "comment" => "ruby.two-fer.string_interpolation",
      "params" => {
        "name_variable" => "iHiD"
      }
    }]
    analysis = create :submission_analysis, data: { comments: }

    expected = [
      {
        type: :informative,
        html: %{<p>As well as string interpolation, another common way to create strings in Ruby is to use <a href="https://www.rubyguides.com/2012/01/ruby-string-formatting/" target="_blank" rel="noreferrer">String#%</a> (perhaps read as "String format").\nFor example:</p>\n<pre><code class="language-ruby">"One for %s, one for you" % iHiD"\n</code></pre>\n} # rubocop:disable Layout/LineLength
      }
    ]
    assert_equal expected, analysis.comments
  end

  test "comments orders correctly for mixed comments" do
    TestHelpers.use_website_copy_test_repo!

    comments = [
      "ruby.two-fer.incorrect_default_param",
      {

        "comment" => "ruby.two-fer.string_interpolation",
        "type" => "essential",
        "params" => {
          "name_variable" => "iHiD"
        }
      }
    ]
    analysis = create :submission_analysis, data: { comments: }

    expected = [
      {
        type: :essential,
        html: %{<p>As well as string interpolation, another common way to create strings in Ruby is to use <a href="https://www.rubyguides.com/2012/01/ruby-string-formatting/" target="_blank" rel="noreferrer">String#%</a> (perhaps read as "String format").\nFor example:</p>\n<pre><code class="language-ruby">"One for %s, one for you" % iHiD"\n</code></pre>\n} # rubocop:disable Layout/LineLength
      },
      {
        type: :informative,
        html: %(<p>What could the default value of the parameter be set to in order to avoid having to use a conditional?</p>\n)
      }
    ]

    assert_equal expected, analysis.comments
  end

  test "has_comments?" do
    refute create(:submission_analysis, data: { comments: nil }).has_comments?
    refute create(:submission_analysis, data: { comments: [] }).has_comments?
    assert create(:submission_analysis, data: { comments: ['foobar'] }).has_comments?
  end

  test "informative comments: short-syntax" do
    comments = ["ruby.two-fer.incorrect_default_param"]
    analysis = create :submission_analysis, data: { comments: }

    assert_equal 1, analysis.num_informative_comments
    assert analysis.has_informative_comments?
  end

  test "informative comments: long-syntax" do
    analysis = create :submission_analysis, data: { comments: [{
      "comment" => "ruby.two-fer.string_interpolation",
      "type": "informative"
    }] }

    assert_equal 1, analysis.num_informative_comments
    assert analysis.has_informative_comments?
  end

  test "informative comments: long-syntax without type" do
    analysis = create :submission_analysis, data: { comments: [{
      "comment" => "ruby.two-fer.string_interpolation"
    }] }

    assert_equal 1, analysis.num_informative_comments
    assert analysis.has_informative_comments?
  end

  test "essential comments: none" do
    comments = ["ruby.two-fer.incorrect_default_param"]
    analysis = create :submission_analysis, data: { comments: }

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

  test "actionable comments: one" do
    analysis = create :submission_analysis, data: { comments: [{
      "comment" => "ruby.two-fer.string_interpolation",
      "type": "actionable"
    }] }

    assert_equal 1, analysis.num_actionable_comments
    assert analysis.has_actionable_comments?
  end

  test "celebratory comments: none" do
    analysis = create :submission_analysis, data: { comments: [] }

    assert_equal 0, analysis.num_celebratory_comments
    refute analysis.has_actionable_comments?
  end

  test "celebratory comments: one" do
    analysis = create :submission_analysis, data: { comments: [{
      "comment" => "ruby.two-fer.string_interpolation",
      "type": "celebratory"
    }] }

    assert_equal 1, analysis.num_celebratory_comments
    assert analysis.has_celebratory_comments?
  end

  test "comments with bad types don't break" do
    Github::Issue::Open.expects(:call).with(
      'ruby-analyzer',
      "Invalid analysis type: this-is-very-bad",
      "A comment was made with the type `this-is-very-bad`. This is invalid."
    )

    analysis = create :submission_analysis, data: { comments: [{
      "comment" => "ruby.two-fer.string_interpolation",
      "type": "this-is-very-bad"
    }] }

    refute analysis.has_informative_comments?
  end

  test "num_comments: without comments" do
    analysis = create :submission_analysis, data: { comments: [] }

    assert_equal 0, analysis.num_comments
  end

  test "num_comments: with comments" do
    analysis = create :submission_analysis, data: {
      comments: [
        "ruby.two-fer.string_interpolation",
        "ruby.two-fer.class_method"
      ]
    }

    assert_equal 2, analysis.num_comments
  end

  # TODO: - Add a test for if the data is empty

  test "scope: with_comments" do
    analysis_1 = create :submission_analysis, data: { comments: ["comment_key"] }
    analysis_2 = create :submission_analysis, data: { comments: ["comment_key"] }
    create :submission_analysis, data: { comments: [] }

    assert_equal [analysis_1, analysis_2], Submission::Analysis.with_comments
  end

  test "track: inferred from submission" do
    submission = create :submission
    analysis = create(:submission_analysis, submission:)

    assert_equal submission.track, analysis.track
  end
end
