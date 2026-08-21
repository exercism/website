require 'test_helper'

class Icons::CheckExistsTest < ActiveSupport::TestCase
  test "true when the icon is in the manifest" do
    setup_s3_icons_manifest!(["exercises/bob.svg"])

    assert Icons::CheckExists.("exercises/bob.svg")
  end

  test "false when the icon isn't in the manifest" do
    setup_s3_icons_manifest!(["exercises/bob.svg"])

    refute Icons::CheckExists.("exercises/flower-field.svg")
  end

  test "true for everything when the manifest is empty" do
    setup_s3_icons_manifest!([])

    assert Icons::CheckExists.("exercises/flower-field.svg")
  end
end
