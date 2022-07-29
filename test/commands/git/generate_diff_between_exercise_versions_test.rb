require "test_helper"

class Git::GenerateDiffBetweenExerciseVersionsTest < ActiveSupport::TestCase
  test "diff for added file" do
    exercise = create :practice_exercise, slug: 'tournament', git_sha: '7a8bd1bbeb0d54a08c39d84d59cc7a8ed54d45aa'

    diff = Git::GenerateDiffBetweenExerciseVersions.(exercise, 'tournament', '23fc26dad93968db3da774cbcc3fc8bb929762c7')

    hints_diff = <<~DIFF
      diff --git a/exercises/practice/tournament/.docs/hints.md b/exercises/practice/tournament/.docs/hints.md
      new file mode 100644
      index 0000000..8eb8b3e
      --- /dev/null
      +++ b/exercises/practice/tournament/.docs/hints.md
      @@ -0,0 +1,3 @@
      +# Hints
      +
      +Hints for tournament
    DIFF
    expected = [{ filename: "hints.md", diff: hints_diff }]
    assert_equal expected, diff
  end

  test "diff for modified file" do
    exercise = create :practice_exercise, slug: 'space-age', git_sha: '9aba0406b02303efe9542e48ab6f4eee0b00e6f1'

    diff = Git::GenerateDiffBetweenExerciseVersions.(exercise, 'space-age', '6f169b92d8500d9ec5f6e69d6927bf732ab5274a')

    instructions_diff = <<~DIFF
      diff --git a/exercises/practice/space-age/.docs/instructions.md b/exercises/practice/space-age/.docs/instructions.md
      index 465e3ca..af034b5 100644
      --- a/exercises/practice/space-age/.docs/instructions.md
      +++ b/exercises/practice/space-age/.docs/instructions.md
      @@ -1,3 +1,3 @@
       # Instructions
      #{' '}
      -README content for space-age
      +Instructions for space-age
    DIFF
    expected = [{ filename: "instructions.md", diff: instructions_diff }]
    assert_equal expected, diff
  end

  test "diff for deleted file" do
    exercise = create :practice_exercise, slug: 'satellite', git_sha: '719afc21a32801f9c7e75ce75ebb5bbcdd025019'

    diff = Git::GenerateDiffBetweenExerciseVersions.(exercise, 'satellite', 'b25b9ac3c9dff32189807dd5ed1e68a65a928f89')

    rubocop_diff = <<~DIFF
      diff --git a/exercises/practice/satellite/rubocop.yml b/exercises/practice/satellite/rubocop.yml
      deleted file mode 100644
      index dec8caa..0000000
      --- a/exercises/practice/satellite/rubocop.yml
      +++ /dev/null
      @@ -1,2 +0,0 @@
      -AllCops:
      -  NewCops: disable
    DIFF
    expected = [{ filename: "rubocop.yml", diff: rubocop_diff }]

    assert_equal expected, diff
  end

  test "diff for deleted file that is not interesting" do
    exercise = create :practice_exercise, slug: 'bob', git_sha: '68c557317e59e5b81cf60736e40a87251b4e441f'

    diff = Git::GenerateDiffBetweenExerciseVersions.(exercise, 'bob', 'e5fb35abbc5b2ae24dcfaafba429f8c46a0102b1')

    assert_empty diff
  end
end
