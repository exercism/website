require 'test_helper'

class Exercise::RepresentationTest < ActiveSupport::TestCase
  include MarkdownFieldMatchers

  test "has markdown fields for feedback" do
    assert_markdown_field(:exercise_representation, :feedback)
  end
end
