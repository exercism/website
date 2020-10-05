require 'test_helper'

class SolutionTest < ActiveSupport::TestCase
  uuid_types = %i[uuid public_uuid mentor_uuid]
  %i[concept_solution practice_solution].each do |solution_type|
    uuid_types.each do |uuid_type|
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
      assert_equal solution.track.git_head_sha, solution.git_sha
      assert_equal solution.exercise.slug, solution.git_slug
    end
  end

  test "downloaded?" do
    refute create(:concept_solution, downloaded_at: nil).downloaded?
    assert create(:concept_solution, downloaded_at: Time.current).downloaded?
  end

  test "update_git_info!" do
    solution = create :concept_solution
    solution.update!(git_sha: "foo", git_slug: "bar")

    # Sanity
    assert_equal "foo", solution.git_sha
    assert_equal "bar", solution.git_slug

    solution.update_git_info!
    assert_equal solution.track.git_head_sha, solution.git_sha
    assert_equal solution.exercise.slug, solution.git_slug
  end

  test "completed and uncompleted" do
    completed = create :concept_solution, completed_at: Time.current
    not_completed = create :concept_solution, completed_at: nil

    assert_equal [completed], Solution.completed
    assert_equal [not_completed], Solution.not_completed
  end
end
