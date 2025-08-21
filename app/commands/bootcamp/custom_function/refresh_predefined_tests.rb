class Bootcamp::CustomFunction::RefreshPredefinedTests
  include Mandate

  def call
    Bootcamp::CustomFunction.where(predefined: true).find_each do |custom_function|
      refresh_function(custom_function)
    end
  end

  private
  def refresh_function(custom_function)
    custom_function_data = Bootcamp::CustomFunction::CreatePredefinedForUser::DATA[custom_function.short_name.to_sym]
    return unless custom_function_data

    user_tests = custom_function.tests.reject { |t| t[:readonly] }

    new_tests = custom_function_data[:tests].map do |args, expected|
      {
        uuid: SecureRandom.uuid,
        args: args.map(&:to_json).join(", "),
        expected: expected.to_json,
        readonly: true
      }
    end

    custom_function.update!(tests: new_tests + user_tests)
  end
end
