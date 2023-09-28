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

    test "automators" do
      expected = [
        { "username": "iHiD", "tracks": ["ruby"] },
        { "username": "ErikSchierboom", "tracks": %w[nim kotlin] }
      ]
      actual = Git::WebsiteCopy.new.automators
      assert_equal expected, actual
    end

    test "update! will update automator roles of listed users" do
      user_1 = create :user, handle: "iHiD"
      user_2 = create :user, handle: "ErikSchierboom"
      ruby = create :track, slug: "ruby"
      nim = create :track, slug: "nim"
      kotlin = create :track, slug: "kotlin"

      create(:user_track_mentorship, user: user_1, track: ruby)
      create(:user_track_mentorship, user: user_2, track: nim)
      create(:user_track_mentorship, user: user_2, track: kotlin)

      User::UpdateAutomatorRole.expects(:defer).with(user_1, ruby)
      User::UpdateAutomatorRole.expects(:defer).with(user_2, nim)
      User::UpdateAutomatorRole.expects(:defer).with(user_2, kotlin)

      website_copy = Git::WebsiteCopy.new
      website_copy.update!
    end
  end
end
