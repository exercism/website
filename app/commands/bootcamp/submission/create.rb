class Bootcamp::Submission::Create
  include Mandate

  initialize_with :solution, :code, :test_results, :readonly_ranges

  def call
    create_submission.tap do |submission|
      solution.update(code:)
      fire_events!(submission)
    end
  end

  private
  def create_submission
    Bootcamp::Submission.create!(
      solution:,
      code:,
      test_results: test_results.to_h,
      readonly_ranges: readonly_ranges || []
    )
  end

  def fire_events!(_submission)
    nil # TODO: Implement this
    # if submission.passed?
    # end
  end
end
