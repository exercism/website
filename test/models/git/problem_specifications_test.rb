require 'test_helper'

class Git::ProblemSpecificationsCopyTest < ActiveSupport::TestCase
  setup do
    TestHelpers.use_problem_specifications_test_repo!
  end

  test "active_exercise_slugs" do
    git = Git::ProblemSpecifications.new

    assert_includes git.active_exercise_slugs, "acronym"
    assert_includes git.active_exercise_slugs, "zipper"
    refute_includes git.active_exercise_slugs, "binary"
    refute_includes git.active_exercise_slugs, "octal"
  end
end
