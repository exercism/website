require 'test_helper'

class SolutionTest < ActiveSupport::TestCase
  %i[concept_solution practice_solution].each do |solution_type|
    test "#{solution_type}: sets uuid" do
      solution = build solution_type, uuid: nil
      assert_nil solution.uuid
      solution.save!
      refute solution.uuid.nil?
    end

    test "#{solution_type}: doesn't override uuid" do
      uuid = "foobar"
      solution = build solution_type, uuid: uuid
      assert_equal uuid, solution.uuid
      solution.save!
      assert_equal uuid, solution.uuid
    end

    test "#{solution_type}: status defaults to 0" do
      solution = create solution_type
      assert_equal 'pending', solution.status
    end

    test "#{solution_type}: git_slug and git_sha are set correctly" do
      solution = create solution_type
      assert_equal solution.git_sha, solution.track.git_head_sha
      assert_equal solution.git_slug, solution.exercise.slug
    end
  end
end
