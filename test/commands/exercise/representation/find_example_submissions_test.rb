require "test_helper"

class Exercise::Representation::FindExampleSubmissionsTest < ActiveSupport::TestCase
  test "returns representation's source submission and latest two submissions with same digest" do
    exercise = create :practice_exercise
    representation = create(:exercise_representation, ast_digest: 'digest', exercise:)

    submission_1 = create(:submission, exercise:)
    create :iteration, submission: submission_1
    create :submission_file, submission: submission_1, filename: "impl.rb", digest: 'digest_1'
    create :submission_representation, submission: submission_1, ast_digest: representation.ast_digest

    submission_2 = create(:submission, exercise:)
    create :iteration, submission: submission_2
    create :submission_file, submission: submission_2, filename: "impl.rb", digest: 'digest_2'
    create :submission_representation, submission: submission_2, ast_digest: representation.ast_digest

    submission_3 = create(:submission, exercise:)
    create :iteration, submission: submission_3
    create :submission_file, submission: submission_3, filename: "impl.rb", digest: 'digest_2'
    create :submission_representation, submission: submission_3, ast_digest: representation.ast_digest

    # Sanity check: different digest
    submission_4 = create(:submission, exercise:)
    create :iteration, submission: submission_4
    create :submission_file, submission: submission_4, filename: "impl.rb", digest: 'digest_3'
    create :submission_representation, submission: submission_4, ast_digest: 'different digest'

    assert_equal [representation.source_submission, submission_3, submission_1],
      Exercise::Representation::FindExampleSubmissions.(representation)
  end

  test "returns three submissions with unique solution file contents but same digest" do
    exercise = create :practice_exercise
    representation = create(:exercise_representation, ast_digest: 'digest', exercise:)

    submission_1 = create(:submission, exercise:)
    create :iteration, submission: submission_1
    create :submission_file, submission: submission_1, filename: "impl.rb", digest: 'digest_1'
    create :submission_representation, submission: submission_1, ast_digest: representation.ast_digest

    # Different submission but with same content
    submission_2 = create(:submission, exercise:)
    create :iteration, submission: submission_2
    create :submission_file, submission: submission_2, filename: "impl.rb", digest: 'digest_1'
    create :submission_representation, submission: submission_2, ast_digest: representation.ast_digest

    # Different submission but with same content
    submission_3 = create(:submission, exercise:)
    create :iteration, submission: submission_3
    create :submission_file, submission: submission_3, filename: "impl.rb", digest: 'digest_2'
    create :submission_representation, submission: submission_3, ast_digest: representation.ast_digest

    submission_4 = create(:submission, exercise:)
    create :iteration, submission: submission_4
    create :submission_file, submission: submission_4, filename: "impl.rb", digest: 'digest_2'
    create :submission_representation, submission: submission_4, ast_digest: representation.ast_digest

    assert_equal [representation.source_submission, submission_4, submission_2],
      Exercise::Representation::FindExampleSubmissions.(representation)
  end
end
