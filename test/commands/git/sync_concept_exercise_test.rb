require "test_helper"

class Git::SyncConceptExerciseTest < ActiveSupport::TestCase
  test "git sync SHA changes to HEAD SHA when there are no changes" do
    exercise = create :concept_exercise, uuid: '71ae39c4-7364-11ea-bc55-0242ac130003', slug: 'lasagna', title: "Lasagna", deprecated: false, git_sha: "ae1a56deb0941ac53da22084af8eb6107d4b5c3a", synced_to_git_sha: "ae1a56deb0941ac53da22084af8eb6107d4b5c3a" # rubocop:disable Layout/LineLength
    exercise.taught_concepts << (create :track_concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e')

    Git::SyncConceptExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
  end

  test "git SHA does not change when there are no changes" do
    exercise = create :concept_exercise, uuid: '71ae39c4-7364-11ea-bc55-0242ac130003', slug: 'lasagna', title: "Lasagna", deprecated: false, git_sha: "ae1a56deb0941ac53da22084af8eb6107d4b5c3a", synced_to_git_sha: "ae1a56deb0941ac53da22084af8eb6107d4b5c3a" # rubocop:disable Layout/LineLength
    exercise.taught_concepts << (create :track_concept, slug: 'basics', uuid: 'fe345fe6-229b-4b4b-a489-4ed3b77a1d7e')

    Git::SyncConceptExercise.(exercise)

    assert_equal "ae1a56deb0941ac53da22084af8eb6107d4b5c3a", exercise.git_sha
  end

  test "git SHA and git sync SHA change to HEAD SHA when there are changes in config.json" do
    exercise = create :concept_exercise, uuid: '1fc8216e-6519-11ea-bc55-0242ac130003', slug: 'lucians-luscious-lasagna', title: "Lucian's Luscious Lasagna", deprecated: false, git_sha: "73177d752b03690a5dd80bd2578e63c9468d4b9f", synced_to_git_sha: "73177d752b03690a5dd80bd2578e63c9468d4b9f" # rubocop:disable Layout/LineLength
    basics = create :track_concept, slug: 'basics', uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215'
    exercise.prerequisites << basics

    Git::SyncConceptExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
    assert_equal exercise.git.head_sha, exercise.git_sha
  end

  test "git SHA and git sync SHA change to HEAD SHA when there are changes in .docs files" do
    exercise = create :concept_exercise, uuid: '1fc8216e-6519-11ea-bc55-0242ac130003', slug: 'lucians-luscious-lasagna', title: "Lucian's Luscious Lasagna", deprecated: false, git_sha: "d3e5f7551a68c85c6134275870e00ba7dfa1d612", synced_to_git_sha: "d3e5f7551a68c85c6134275870e00ba7dfa1d612" # rubocop:disable Layout/LineLength
    basics = create :track_concept, slug: 'basics', uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215'
    exercise.prerequisites << basics

    Git::SyncConceptExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
    assert_equal exercise.git.head_sha, exercise.git_sha
  end

  test "git SHA and git sync SHA change to HEAD SHA when there are changes in .meta files" do
    exercise = create :concept_exercise, uuid: '1fc8216e-6519-11ea-bc55-0242ac130003', slug: 'lucians-luscious-lasagna', title: "Lucian's Luscious Lasagna", deprecated: false, git_sha: "14339ac3bc87dd996cd71ae285c252b27c1f45b8", synced_to_git_sha: "14339ac3bc87dd996cd71ae285c252b27c1f45b8" # rubocop:disable Layout/LineLength
    basics = create :track_concept, slug: 'basics', uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215'
    exercise.prerequisites << basics

    Git::SyncConceptExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
    assert_equal exercise.git.head_sha, exercise.git_sha
  end

  test "git SHA and git sync SHA change to HEAD SHA when there are changes in track-specific files" do
    exercise = create :concept_exercise, uuid: '1fc8216e-6519-11ea-bc55-0242ac130003', slug: 'lucians-luscious-lasagna', title: "Lucian's Luscious Lasagna", deprecated: false, git_sha: "73177d752b03690a5dd80bd2578e63c9468d4b9f", synced_to_git_sha: "73177d752b03690a5dd80bd2578e63c9468d4b9f" # rubocop:disable Layout/LineLength
    basics = create :track_concept, slug: 'basics', uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215'
    exercise.prerequisites << basics

    Git::SyncConceptExercise.(exercise)

    assert_equal exercise.git.head_sha, exercise.synced_to_git_sha
    assert_equal exercise.git.head_sha, exercise.git_sha
  end

  test "metadata is updated when there are changes in config.json" do
    exercise = create :concept_exercise, uuid: '1fc8216e-6519-11ea-bc55-0242ac130003', slug: 'lucians-luscious-lasagna', title: "Lucian's Luscious Lasagna", deprecated: false, git_sha: "73177d752b03690a5dd80bd2578e63c9468d4b9f", synced_to_git_sha: "73177d752b03690a5dd80bd2578e63c9468d4b9f" # rubocop:disable Layout/LineLength
    basics = create :track_concept, slug: 'basics', uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215'
    exercise.prerequisites << basics

    Git::SyncConceptExercise.(exercise)

    assert exercise.deprecated
  end

  test "removes taught concepts that are not in config.json" do
    numbers = create :track_concept, slug: 'numbers', uuid: 'd0fe01c7-d94b-4d6b-92a7-a0055c5704a3'
    conditionals = create :track_concept, slug: 'conditionals', uuid: '2d2c2485-7655-40f0-9bd2-476fc322e67f'
    basics = create :track_concept, slug: 'basics', uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215'
    exercise = create :concept_exercise, uuid: '6ea2765e-5885-11ea-82b4-0242ac130003', slug: 'cars-assemble', title: 'Cars, Assemble!', git_sha: "27769be83c98b6cc273bc50bbcd2cd31c569cc92", synced_to_git_sha: "27769be83c98b6cc273bc50bbcd2cd31c569cc92" # rubocop:disable Layout/LineLength
    exercise.prerequisites << basics
    exercise.taught_concepts << conditionals
    exercise.taught_concepts << numbers

    Git::SyncConceptExercise.(exercise)

    refute_includes exercise.taught_concepts, numbers
  end

  test "adds new taught concepts defined in config.json" do
    create :track_concept, slug: 'numbers', uuid: 'd0fe01c7-d94b-4d6b-92a7-a0055c5704a3'
    conditionals = create :track_concept, slug: 'conditionals', uuid: '2d2c2485-7655-40f0-9bd2-476fc322e67f'
    basics = create :track_concept, slug: 'basics', uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215'
    strings = create :track_concept, slug: 'strings', uuid: '8a3e23fd-aa42-42c3-9dbd-c26159fd6774'
    exercise = create :concept_exercise, uuid: '9c2aad8a-53ee-11ea-8d77-2e728ce88125', slug: 'log-levels', title: 'Log Levels', deprecated: true, git_sha: "6d0fa1608d257f76ce990eaa5aedf45305bc0a0f", synced_to_git_sha: "6d0fa1608d257f76ce990eaa5aedf45305bc0a0f" # rubocop:disable Layout/LineLength
    exercise.prerequisites << basics
    exercise.taught_concepts << strings

    Git::SyncConceptExercise.(exercise)

    assert_includes exercise.taught_concepts, conditionals
  end

  test "removes prerequisites that are not in config.json" do
    conditionals = create :track_concept, slug: 'conditionals', uuid: '2d2c2485-7655-40f0-9bd2-476fc322e67f'
    basics = create :track_concept, slug: 'basics', uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215'
    strings = create :track_concept, slug: 'strings', uuid: '8a3e23fd-aa42-42c3-9dbd-c26159fd6774'
    create :track_concept, slug: 'numbers', uuid: 'd0fe01c7-d94b-4d6b-92a7-a0055c5704a3'
    exercise = create :concept_exercise, uuid: '9c2aad8a-53ee-11ea-8d77-2e728ce88125', slug: 'log-levels', title: 'Log Levels', deprecated: true, git_sha: "4dbfbaca6c68c908d51a979d26baa48ceaefa5c1", synced_to_git_sha: "4dbfbaca6c68c908d51a979d26baa48ceaefa5c1" # rubocop:disable Layout/LineLength
    exercise.prerequisites << basics
    exercise.prerequisites << conditionals
    exercise.taught_concepts << strings

    Git::SyncConceptExercise.(exercise)

    refute_includes exercise.prerequisites, conditionals
  end

  test "adds new prerequisites defined in config.json" do
    conditionals = create :track_concept, slug: 'conditionals', uuid: '2d2c2485-7655-40f0-9bd2-476fc322e67f'
    basics = create :track_concept, slug: 'basics', uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215'
    strings = create :track_concept, slug: 'strings', uuid: '8a3e23fd-aa42-42c3-9dbd-c26159fd6774'
    numbers = create :track_concept, slug: 'numbers', uuid: 'd0fe01c7-d94b-4d6b-92a7-a0055c5704a3'
    exercise = create :concept_exercise, uuid: '9c2aad8a-53ee-11ea-8d77-2e728ce88125', slug: 'log-levels', title: 'Log Levels', deprecated: true, git_sha: "b6c940e2c321c9b95542bdd5e5018bf447e0fa8a", synced_to_git_sha: "b6c940e2c321c9b95542bdd5e5018bf447e0fa8a" # rubocop:disable Layout/LineLength
    exercise.prerequisites << basics
    exercise.prerequisites << conditionals
    exercise.taught_concepts << strings

    Git::SyncConceptExercise.(exercise)

    assert_includes exercise.prerequisites, numbers
  end

  test "adds new authors that are in .meta/config.json" do
    conditionals = create :track_concept, slug: 'conditionals', uuid: '2d2c2485-7655-40f0-9bd2-476fc322e67f'
    basics = create :track_concept, slug: 'basics', uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215'
    exercise = create :concept_exercise, uuid: '6ea2765e-5885-11ea-82b4-0242ac130003', slug: 'cars-assemble', title: 'Cars, Assemble!', git_sha: "ec9778d42d14df4ae8f8709f9b24acc8ca837432", synced_to_git_sha: "ec9778d42d14df4ae8f8709f9b24acc8ca837432" # rubocop:disable Layout/LineLength
    exercise.prerequisites << basics
    exercise.taught_concepts << conditionals
    first_author = create :user, handle: "ErikSchierboom"
    second_author = create :user, handle: "RobKeim"

    Git::SyncConceptExercise.(exercise)

    assert_includes exercise.authors, first_author
    assert_includes exercise.authors, second_author
  end

  test "removes authors that are not in .meta/config.json" do
    conditionals = create :track_concept, slug: 'conditionals', uuid: '2d2c2485-7655-40f0-9bd2-476fc322e67f'
    strings = create :track_concept, slug: 'strings', uuid: '8a3e23fd-aa42-42c3-9dbd-c26159fd6774'
    pattern_matching = create :track_concept, slug: 'pattern-matching', uuid: '3439b5d6-6e1b-486b-989d-9f7e8f9eb732' # rubocop:disable Layout/LineLength
    exercise = create :concept_exercise, uuid: 'd605385d-fd8a-45fa-a320-4d7c40213769', slug: 'guessing-game', title: 'Guessing Game', git_sha: "bb8b38cb441e154475fd1d7b53efeddfc446fdda", synced_to_git_sha: "bb8b38cb441e154475fd1d7b53efeddfc446fdda" # rubocop:disable Layout/LineLength
    exercise.prerequisites << conditionals
    exercise.prerequisites << strings
    exercise.taught_concepts << pattern_matching
    first_author = create :user, handle: "ErikSchierboom"
    second_author = create :user, handle: "SleeplessByte"

    Git::SyncConceptExercise.(exercise)

    refute_includes exercise.authors, first_author
    assert_includes exercise.authors, second_author
  end

  test "adds reputation token for new author" do
    conditionals = create :track_concept, slug: 'conditionals', uuid: '2d2c2485-7655-40f0-9bd2-476fc322e67f'
    basics = create :track_concept, slug: 'basics', uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215'
    exercise = create :concept_exercise, uuid: '6ea2765e-5885-11ea-82b4-0242ac130003', slug: 'cars-assemble', title: 'Cars, Assemble!', git_sha: "ec9778d42d14df4ae8f8709f9b24acc8ca837432", synced_to_git_sha: "ec9778d42d14df4ae8f8709f9b24acc8ca837432" # rubocop:disable Layout/LineLength
    exercise.prerequisites << basics
    exercise.taught_concepts << conditionals
    second_author = create :user, handle: "RobKeim"

    Git::SyncConceptExercise.(exercise)

    new_authorship = exercise.authorships.find_by(author: second_author)
    new_author_rep_token = second_author.reputation_tokens.find_by(context: new_authorship)
    assert_equal :authoring, new_author_rep_token.category
    assert_equal 'authored_exercise', new_author_rep_token.reason
    assert_equal 10, new_author_rep_token.value
  end

  test "only adds reputation token for new author" do
    conditionals = create :track_concept, slug: 'conditionals', uuid: '2d2c2485-7655-40f0-9bd2-476fc322e67f'
    basics = create :track_concept, slug: 'basics', uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215'
    exercise = create :concept_exercise, uuid: '6ea2765e-5885-11ea-82b4-0242ac130003', slug: 'cars-assemble', title: 'Cars, Assemble!', git_sha: "ec9778d42d14df4ae8f8709f9b24acc8ca837432", synced_to_git_sha: "ec9778d42d14df4ae8f8709f9b24acc8ca837432" # rubocop:disable Layout/LineLength
    exercise.prerequisites << basics
    exercise.taught_concepts << conditionals
    first_author = create :user, handle: "ErikSchierboom"
    first_author_authorship = create :exercise_authorship, exercise: exercise, author: first_author
    create :user_reputation_token, user: first_author, context: first_author_authorship, value: 10, reason: "authored_exercise", category: "authoring" # rubocop:disable Layout/LineLength

    Git::SyncConceptExercise.(exercise)

    assert_equal 1, first_author.reputation_tokens.where(category: "authoring").count
  end

  test "adds contributors that are in .meta/config.json" do
    conditionals = create :track_concept, slug: 'conditionals', uuid: '2d2c2485-7655-40f0-9bd2-476fc322e67f'
    basics = create :track_concept, slug: 'basics', uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215'
    exercise = create :concept_exercise, uuid: '6ea2765e-5885-11ea-82b4-0242ac130003', slug: 'cars-assemble', title: 'Cars, Assemble!', git_sha: "e47f3bb23b5108793e2acd333bec7bccbb5193fd", synced_to_git_sha: "e47f3bb23b5108793e2acd333bec7bccbb5193fd" # rubocop:disable Layout/LineLength
    exercise.prerequisites << basics
    exercise.taught_concepts << conditionals
    contributor = create :user, handle: "SleeplessByte"

    Git::SyncConceptExercise.(exercise)

    assert_includes exercise.contributors, contributor
  end

  test "removes contributors that are not in .meta/config.json" do
    conditionals = create :track_concept, slug: 'conditionals', uuid: '2d2c2485-7655-40f0-9bd2-476fc322e67f'
    strings = create :track_concept, slug: 'strings', uuid: '8a3e23fd-aa42-42c3-9dbd-c26159fd6774'
    pattern_matching = create :track_concept, slug: 'pattern-matching', uuid: '3439b5d6-6e1b-486b-989d-9f7e8f9eb732' # rubocop:disable Layout/LineLength
    exercise = create :concept_exercise, uuid: 'd605385d-fd8a-45fa-a320-4d7c40213769', slug: 'guessing-game', title: 'Guessing Game', git_sha: "bb8b38cb441e154475fd1d7b53efeddfc446fdda", synced_to_git_sha: "bb8b38cb441e154475fd1d7b53efeddfc446fdda" # rubocop:disable Layout/LineLength
    exercise.prerequisites << conditionals
    exercise.prerequisites << strings
    exercise.taught_concepts << pattern_matching
    first_contributor = create :user, handle: "ErikSchierboom"
    second_contributor = create :user, handle: "neenjaw"

    Git::SyncConceptExercise.(exercise)

    refute_includes exercise.contributors, first_contributor
    assert_includes exercise.contributors, second_contributor
  end

  test "adds reputation token for new contributor" do
    conditionals = create :track_concept, slug: 'conditionals', uuid: '2d2c2485-7655-40f0-9bd2-476fc322e67f'
    basics = create :track_concept, slug: 'basics', uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215'
    exercise = create :concept_exercise, uuid: '6ea2765e-5885-11ea-82b4-0242ac130003', slug: 'cars-assemble', title: 'Cars, Assemble!', git_sha: "e47f3bb23b5108793e2acd333bec7bccbb5193fd", synced_to_git_sha: "e47f3bb23b5108793e2acd333bec7bccbb5193fd" # rubocop:disable Layout/LineLength
    exercise.prerequisites << basics
    exercise.taught_concepts << conditionals
    contributor = create :user, handle: "SleeplessByte"

    Git::SyncConceptExercise.(exercise)

    new_contributorship = exercise.contributorships.find_by(contributor: contributor)
    new_contributor_rep_token = contributor.reputation_tokens.find_by(context: new_contributorship)
    assert_equal 'contributed_to_exercise', new_contributor_rep_token.reason
    assert_equal :authoring, new_contributor_rep_token.category
    assert_equal 5, new_contributor_rep_token.value
  end

  test "only adds reputation token for new contributor" do
    conditionals = create :track_concept, slug: 'conditionals', uuid: '2d2c2485-7655-40f0-9bd2-476fc322e67f'
    basics = create :track_concept, slug: 'basics', uuid: 'f91b9627-803e-47fd-8bba-1a8f113b5215'
    exercise = create :concept_exercise, uuid: '6ea2765e-5885-11ea-82b4-0242ac130003', slug: 'cars-assemble', title: 'Cars, Assemble!', git_sha: "e47f3bb23b5108793e2acd333bec7bccbb5193fd", synced_to_git_sha: "e47f3bb23b5108793e2acd333bec7bccbb5193fd" # rubocop:disable Layout/LineLength
    exercise.prerequisites << basics
    exercise.taught_concepts << conditionals
    contributor = create :user, handle: "SleeplessByte"
    contributor_contributorship = create :exercise_contributorship, exercise: exercise, contributor: contributor
    create :user_reputation_token, user: contributor, context: contributor_contributorship, value: 5, reason: "contributed_to_exercise", category: "authoring" # rubocop:disable Layout/LineLength

    Git::SyncConceptExercise.(exercise)

    assert_equal 1, contributor.reputation_tokens.where(category: "authoring").count
  end
end
