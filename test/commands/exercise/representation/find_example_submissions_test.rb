require "test_helper"

class Exercise::Representation::FindExampleSubmissionsTest < ActiveSupport::TestCase
  test "returns latest three submission with same digest" do
    representation = create :exercise_representation, ast_digest: 'digest'

    submission_1 = create :submission
    create :iteration, submission: submission_1
    create :submission_file, submission: submission_1, filename: "impl.rb", content: "Impl // Foo"
    create :submission_representation, submission: submission_1, ast_digest: representation.ast_digest

    submission_2 = create :submission
    create :iteration, submission: submission_2
    create :submission_file, submission: submission_2, filename: "impl.rb", content: "Impl // Foo"
    create :submission_representation, submission: submission_2, ast_digest: representation.ast_digest

    submission_3 = create :submission
    create :iteration, submission: submission_3
    create :submission_file, submission: submission_3, filename: "impl.rb", content: "Impl // Bar"
    create :submission_representation, submission: submission_3, ast_digest: representation.ast_digest

    submission_4 = create :submission
    create :iteration, submission: submission_4
    create :submission_file, submission: submission_4, filename: "impl.rb", content: "Impl // Baz"
    create :submission_representation, submission: submission_4, ast_digest: representation.ast_digest

    # Sanity check: different digest
    submission_5 = create :submission
    create :iteration, submission: submission_5
    create :submission_file, submission: submission_5, filename: "impl.rb", content: "Impl // Dez"
    create :submission_representation, submission: submission_5, ast_digest: 'different digest'

    assert_equal [submission_4, submission_3, submission_2], Exercise::Representation::FindExampleSubmissions.(representation)
  end

  test "returns three submissions with unique solution files but same digest" do
    representation = create :exercise_representation, ast_digest: 'digest'

    submission_1 = create :submission
    create :iteration, submission: submission_1
    create :submission_file, submission: submission_1, filename: "impl.rb", content: "Impl // Foo"
    create :submission_representation, submission: submission_1, ast_digest: representation.ast_digest

    # Different submission but with same content
    submission_2 = create :submission
    create :iteration, submission: submission_2
    create :submission_file, submission: submission_2, filename: "impl.rb", content: "Impl // Foo"
    create :submission_representation, submission: submission_2, ast_digest: representation.ast_digest

    submission_3 = create :submission
    create :iteration, submission: submission_3
    create :submission_file, submission: submission_3, filename: "impl.rb", content: "Impl // Bar"
    create :submission_representation, submission: submission_3, ast_digest: representation.ast_digest

    # Different submission but with same content
    submission_4 = create :submission
    create :iteration, submission: submission_4
    create :submission_file, submission: submission_4, filename: "impl.rb", content: "Impl // Baz"
    create :submission_representation, submission: submission_4, ast_digest: representation.ast_digest

    submission_5 = create :submission
    create :iteration, submission: submission_5
    create :submission_file, submission: submission_5, filename: "impl.rb", content: "Impl // Baz"
    create :submission_representation, submission: submission_5, ast_digest: representation.ast_digest

    assert_equal [submission_5, submission_3, submission_2], Exercise::Representation::FindExampleSubmissions.(representation)
  end
end
