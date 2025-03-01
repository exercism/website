class Bootcamp::CustomFunction::CreatePredefinedForUser
  include Mandate

  initialize_with :user

  def call
    DATA.each do |data|
      next if user.bootcamp_custom_functions.exists?(name: data[:name])

      fn_name = "my##{data[:name]}"
      code_parts = ["function #{fn_name}"]
      code_parts << "with #{data[:params].join(', ')}" if data[:params].present?
      code_parts << "do\n\n\nend"

      tests = data[:tests].map do |args, expected|
        {
          uuid: SecureRandom.uuid,
          args: args.map(&:to_json).join(", "),
          expected: expected.to_json
        }
      end

      user.bootcamp_custom_functions.create!(
        name: data[:name],
        description: data[:description],
        code: code_parts.join(" "),
        predefined: true,
        fn_name:,
        fn_arity: data[:params].size,
        tests:
      )
    end
  end

  DATA = [
    {
      name: "starts_with",
      description: "Check if a string starts with a given prefix.",
      params: %w[string prefix],
      tests: {
        %w[hello hello] => true,
        %w[hello he] => true,
        %w[hello h] => true,
        ["", ""] => true,
        %w[hello bye] => false,
        ["hello", "hello there"] => false
      }
    },
    {
      name: "length",
      description: "Returns the length of a string or list.",
      params: ["measurable"],
      tests: {
        ["hello"] => 5,
        [["he", 1, false]] => 3,
        [""] => 0,
        [[]] => 0
      }
    }
  ].freeze
end
