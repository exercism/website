require "test_helper"

class Solution::GenerateTestRunConfigTest < ActiveSupport::TestCase
  test "nil for a track whose tests run on the server" do
    solution = create :practice_solution, exercise: create(:practice_exercise, track: create(:track, slug: "ruby"))

    assert_nil Solution::GenerateTestRunConfig.(solution)
  end

  test "files for a track whose tests run in the browser" do
    solution = create :practice_solution, exercise: create(:practice_exercise, track: create(:track, slug: "jq"))
    Git::Exercise.any_instance.stubs(:tooling_files).returns({ "test.bats" => "..." })

    assert_equal({ files: { "test.bats" => "..." } }, Solution::GenerateTestRunConfig.(solution))
  end

  test "files when experimental, whatever the track" do
    solution = create :practice_solution, exercise: create(:practice_exercise, track: create(:track, slug: "ruby"))
    Git::Exercise.any_instance.stubs(:tooling_files).returns({ "test.rb" => "..." })

    assert_equal({ files: { "test.rb" => "..." } }, Solution::GenerateTestRunConfig.(solution, experimental: true))
  end
end
