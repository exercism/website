require 'test_helper'

module Git
  class WebsiteCopyTest < ActiveSupport::TestCase
    setup do
      TestHelpers.use_website_copy_test_repo!
    end

    test "analysis_comment_for" do
      expected = "What could the default value of the parameter be set to in order to avoid having to use a conditional?\n"
      actual = Git::WebsiteCopy.new.analysis_comment_for('ruby.two-fer.incorrect_default_param')
      assert_equal expected, actual
    end

    test "mentor_notes_for_exercise" do
      expected = "Clock introduces students to the concept of value objects and modular arithmetic.\n\nNote: This exercise changes a lot depending on which version the person has solved.\n" # rubocop:disable Layout/LineLength
      actual = Git::WebsiteCopy.new.mentor_notes_for_exercise('ruby', 'clock')
      assert_equal expected, actual
    end
  end
end
