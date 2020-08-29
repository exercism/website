require 'test_helper'

class SolutionTest < ActiveSupport::TestCase
  %i[concept_solution practice_solution].each do |solution_type|
    %i[uuid public_uuid mentor_uuid].each do |uuid_type|
      test "#{solution_type}: sets #{uuid_type}" do
        solution = build solution_type, uuid_type => nil
        assert_nil solution.send(uuid_type)
        solution.save!
        refute solution.send(uuid_type).nil?
      end

      test "#{solution_type}: doesn't override #{uuid_type}" do
        uuid = "foobar"
        solution = build solution_type, uuid_type => uuid
        assert_equal uuid, solution.send(uuid_type)
        solution.save!
        assert_equal uuid, solution.send(uuid_type)
      end
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
