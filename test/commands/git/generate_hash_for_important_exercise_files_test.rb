require "test_helper"

class Git::GenerateHashForImportantExerciseFilesTest < ActiveSupport::TestCase
  test "generates hash" do
    exercise = create :practice_exercise, slug: 'bob', git_sha: '2e25f799c1830b93a8ad65a2bbbb1c50f381e639'

    hash = Git::GenerateHashForImportantExerciseFiles.(exercise)

    assert_equal 'b72b0958a135cddd775bf116c128e6e859bf11e4', hash
  end

  test "hash is same if important files have not changed between commits" do
    before_exercise = create :practice_exercise, slug: 'bob', git_sha: 'ef19c86ee73dfbd3df8f3d49251008783a51de91'
    after_exercise = create :practice_exercise, slug: 'bob', git_sha: '2e25f799c1830b93a8ad65a2bbbb1c50f381e639'

    before_hash = Git::GenerateHashForImportantExerciseFiles.(before_exercise)
    after_hash = Git::GenerateHashForImportantExerciseFiles.(after_exercise)

    assert_equal before_hash, after_hash
  end

  test "hash is same if non-important files have changed between commits" do
    before_exercise = create :practice_exercise, slug: 'isogram', git_sha: '2a2615f424ce84a33288487dc05ad706d3579671'
    after_exercise = create :practice_exercise, slug: 'isogram', git_sha: '02ec958028654f2a57655ec14f76ad1ea91a092c'

    before_hash = Git::GenerateHashForImportantExerciseFiles.(before_exercise)
    after_hash = Git::GenerateHashForImportantExerciseFiles.(after_exercise)

    assert_equal before_hash, after_hash
  end

  test "hash is different if important files have changed between commits" do
    before_exercise = create :practice_exercise, slug: 'allergies', git_sha: '6f169b92d8500d9ec5f6e69d6927bf732ab5274a'
    after_exercise = create :practice_exercise, slug: 'allergies', git_sha: '9aba0406b02303efe9542e48ab6f4eee0b00e6f1'

    before_hash = Git::GenerateHashForImportantExerciseFiles.(before_exercise)
    after_hash = Git::GenerateHashForImportantExerciseFiles.(after_exercise)

    refute_equal before_hash, after_hash
  end
end
