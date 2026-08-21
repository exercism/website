require 'test_helper'

class Icons::CheckExistsTest < ActiveSupport::TestCase
  test "true when the icon is in the manifest" do
    stub_manifest(["exercises/bob.svg"])

    assert Icons::CheckExists.("exercises/bob.svg")
  end

  test "false when the icon isn't in the manifest" do
    stub_manifest(["exercises/bob.svg"])

    refute Icons::CheckExists.("exercises/flower-field.svg")
  end

  test "true for everything when the manifest is empty" do
    stub_manifest([])

    assert Icons::CheckExists.("exercises/flower-field.svg")
  end

  def stub_manifest(paths)
    stub_request(:get, "https://assets.exercism.org/manifest.json").
      to_return(status: 200, body: paths.to_json)
  end
end
