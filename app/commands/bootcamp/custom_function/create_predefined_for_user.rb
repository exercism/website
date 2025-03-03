class Bootcamp::CustomFunction::CreatePredefinedForUser
  include Mandate

  initialize_with :user, :name

  def call
    data = DATA[name.to_sym]
    return unless data

    existing_fn = user.bootcamp_custom_functions.find_by(name:)
    return existing_fn if existing_fn

    fn_name = "my##{name}"
    code_parts = ["function #{fn_name}"]
    code_parts << "with #{data[:params].join(', ')}" if data[:params].present?
    code_parts << "do\n\n\nend"

    tests = data[:tests].map do |args, expected|
      {
        uuid: SecureRandom.uuid,
        args: args.map(&:to_json).join(", "),
        expected: expected.to_json,
        readonly: true
      }
    end

    user.bootcamp_custom_functions.create!(
      name: fn_name,
      description: data[:description],
      code: code_parts.join(" "),
      predefined: true,
      arity: data[:params].size,
      tests:
    )
  end

  DATA = {
    starts_with: {
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
    length: {
      description: "Returns the length of a string or list.",
      params: ["measurable"],
      tests: {
        ["hello"] => 5,
        [["he", 1, false]] => 3,
        [""] => 0,
        [[]] => 0
      }
    },
    contains: {
      description: "Returns a boolean informing you of whether a list contains an element, or a string contains a character.",
      params: %w[haystack needle],
      tests: {
        %w[hello h] => true,
        %w[hello o] => true,
        %w[hello a] => false,
        ["hello world", " "] => true,
        ["hello world", "w"] => true,
        [["he", 1, false], "he"] => true,
        [["he", 1, false], 1] => true,
        [["he", 1, false], false] => true,
        [["he", 1, false], "foo"] => false,
        ["", ""] => true,
        [[], []] => false
      }
    },
    to_sentence: {
      description: "Turns a list into a sentence using commas and 'and'.",
      params: %w[list oxford_comma],
      tests: {
        [%w[the cat sat mat], true] => "the, cat, sat, and mat",
        [%w[the cat sat mat], false] => "the, cat, sat and mat",
        [%w[the mat], true] => "the, and mat",
        [%w[the mat], false] => "the and mat",
        [["the"], true] => "the",
        [["the"], false] => "the",
        [[], true] => "",
        [[], false] => ""
      }
    }
  }.freeze
end
