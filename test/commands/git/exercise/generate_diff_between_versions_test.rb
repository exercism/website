require "test_helper"

class Git::Exercise::GenerateDiffBetweenVersionsTest < ActiveSupport::TestCase
  test "diff for added file" do
    exercise = create :practice_exercise, slug: 'tournament', git_sha: '7a8bd1bbeb0d54a08c39d84d59cc7a8ed54d45aa'

    diff = Git::Exercise::GenerateDiffBetweenVersions.(exercise, 'tournament', '23fc26dad93968db3da774cbcc3fc8bb929762c7')

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
    expected = [{ relative_path: ".docs/hints.md", diff: hints_diff }]
    assert_equal expected, diff
  end

  test "diff for added file that is not interesting" do
    exercise = create :practice_exercise, slug: 'leap', git_sha: '16308d8a109b952e87ca6198c13589b89c2eeab9'

    diff = Git::Exercise::GenerateDiffBetweenVersions.(exercise, 'leap', '719afc21a32801f9c7e75ce75ebb5bbcdd025019')

    assert_empty diff
  end

  test "diff for modified file" do
    exercise = create :practice_exercise, slug: 'space-age', git_sha: '9aba0406b02303efe9542e48ab6f4eee0b00e6f1'

    diff = Git::Exercise::GenerateDiffBetweenVersions.(exercise, 'space-age', '6f169b92d8500d9ec5f6e69d6927bf732ab5274a')

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
    expected = [{ relative_path: ".docs/instructions.md", diff: instructions_diff }]
    assert_equal expected, diff
  end

  test "diff for modified file that is not interesting" do
    exercise = create :practice_exercise, slug: 'leap', git_sha: '31673dc5c3cde7ecc932f795d9810e71c1a1c86d'

    diff = Git::Exercise::GenerateDiffBetweenVersions.(exercise, 'leap', '16308d8a109b952e87ca6198c13589b89c2eeab9')

    assert_empty diff
  end

  test "diff for deleted file" do
    exercise = create :practice_exercise, slug: 'satellite', git_sha: '719afc21a32801f9c7e75ce75ebb5bbcdd025019'

    diff = Git::Exercise::GenerateDiffBetweenVersions.(exercise, 'satellite', 'b25b9ac3c9dff32189807dd5ed1e68a65a928f89')

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
    expected = [{ relative_path: "rubocop.yml", diff: rubocop_diff }]

    assert_equal expected, diff
  end

  test "diff for deleted file that is not interesting" do
    exercise = create :practice_exercise, slug: 'bob', git_sha: '68c557317e59e5b81cf60736e40a87251b4e441f'

    diff = Git::Exercise::GenerateDiffBetweenVersions.(exercise, 'bob', 'e5fb35abbc5b2ae24dcfaafba429f8c46a0102b1')

    assert_empty diff
  end

  test "diff for modified config includes file as interesting that was added to git previously" do
    exercise = create :practice_exercise, slug: 'leap', git_sha: '7ab5c2dfc18b9d63529c4a96197d7ad4c4976e93'

    diff = Git::Exercise::GenerateDiffBetweenVersions.(exercise, 'leap', '31673dc5c3cde7ecc932f795d9810e71c1a1c86d')

    rubocop_diff = <<~DIFF
      diff --git a/exercises/practice/leap/rubocop.yml b/exercises/practice/leap/rubocop.yml
      new file mode 100644
      index 0000000..3b64504
      --- /dev/null
      +++ b/exercises/practice/leap/rubocop.yml
      @@ -0,0 +1,2 @@
      +AllCops:
      +  NewCops: enable
    DIFF
    expected = [{ relative_path: "rubocop.yml", diff: rubocop_diff }]
    assert_equal expected, diff
  end

  test "diff for modified config excludes file as interesting that was added to git previously" do
    exercise = create :practice_exercise, slug: 'leap', git_sha: '3213d5c55b71d33f4bedbe36116cea8188f34d0a'

    diff = Git::Exercise::GenerateDiffBetweenVersions.(exercise, 'leap', '7ab5c2dfc18b9d63529c4a96197d7ad4c4976e93')

    # Excluding a file as interesting but with the file not removed from git,
    # doesn't have any real consequences for the student.
    # 1. If the student had submitted the file previously, the file will still show up
    # in the editor/be downloaded via the CLI.
    # 2. If the student has not submitted the file, the file won't show up in the editor (which is fine)
    # and the CLI will still download it.
    assert_empty diff
  end

  test "diff for combination of added/updated/removed files" do
    exercise = create :practice_exercise, slug: 'tournament', git_sha: '9378b6f648d840fa6f99d568d43483c95c08789f'

    diff = Git::Exercise::GenerateDiffBetweenVersions.(exercise, 'tournament', 'dd3dda8ddb502aec82042e1544dc071279413f66')

    helper_diff = <<~DIFF
      diff --git a/exercises/practice/tournament/helper.rb b/exercises/practice/tournament/helper.rb
      deleted file mode 100644
      index 1bea883..0000000
      --- a/exercises/practice/tournament/helper.rb
      +++ /dev/null
      @@ -1 +0,0 @@
      -helper for tournament
    DIFF

    rubocop_diff = <<~DIFF
      diff --git a/exercises/practice/tournament/rubocop.yml b/exercises/practice/tournament/rubocop.yml
      new file mode 100644
      index 0000000..3b64504
      --- /dev/null
      +++ b/exercises/practice/tournament/rubocop.yml
      @@ -0,0 +1,2 @@
      +AllCops:
      +  NewCops: enable
    DIFF

    tournament_test_diff = <<~DIFF
      diff --git a/exercises/practice/tournament/tournament_test.rb b/exercises/practice/tournament/tournament_test.rb
      index 2fe4fad..87ca191 100644
      --- a/exercises/practice/tournament/tournament_test.rb
      +++ b/exercises/practice/tournament/tournament_test.rb
      @@ -1 +1 @@
      -test content for tournament
      +test content for tournament exercise
    DIFF

    expected = [
      { relative_path: "helper.rb", diff: helper_diff },
      { relative_path: "rubocop.yml", diff: rubocop_diff },
      { relative_path: "tournament_test.rb", diff: tournament_test_diff }
    ]
    assert_equal expected, diff
  end

  test "relative path is returned" do
    exercise = create :practice_exercise, slug: 'tournament', git_sha: '7a8bd1bbeb0d54a08c39d84d59cc7a8ed54d45aa'

    diff = Git::Exercise::GenerateDiffBetweenVersions.(exercise, 'tournament', '23fc26dad93968db3da774cbcc3fc8bb929762c7')

    assert_equal ".docs/hints.md", diff.first[:relative_path]
  end

  test "file that changes in both git and interesting file paths is returned only once" do
    exercise = create :practice_exercise, slug: 'tournament', git_sha: 'dd3dda8ddb502aec82042e1544dc071279413f66'

    diff = Git::Exercise::GenerateDiffBetweenVersions.(exercise, 'tournament', '3213d5c55b71d33f4bedbe36116cea8188f34d0a')

    relative_filepaths = diff.map { |d| d[:relative_path] }
    assert_equal relative_filepaths.uniq, relative_filepaths
  end
end
