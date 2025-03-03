class Bootcamp::Submission::Create
  include Mandate

  initialize_with :solution, :code, :test_results, :readonly_ranges, :custom_functions

  def call
    create_submission.tap do |submission|
      update_solution!(submission)
    end
  end

  private
  def create_submission
    Bootcamp::Submission.create!(
      solution:,
      code:,
      test_results: test_results.to_h,
      readonly_ranges: readonly_ranges || [],
      custom_functions: custom_functions || []
    )
  end

  def update_solution!(submission)
    solution.update(code:)

    case submission.status
    when :pass
      solution.update!(passed_basic_tests: true)
    when :pass_bonus
      solution.update!(
        passed_basic_tests: true,
        passed_bonus_tests: true
      )
    end
  end

  def fire_events!(_submission)
    nil # TODO: Implement this
    # if submission.passed?
    # end
  end
end
