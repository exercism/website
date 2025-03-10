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
        [["he", 1, false], "foo"] => false
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
    },
    has_key: {
      description: "Determines whether a dictionary has a specific key, and returns the result as a boolean.",
      params: %w[dict key],
      tests: {
        [{ "name": "Jeremy" }, "name"] => true,
        [{ "name": "Jeremy", "age": 41 }, "age"] => true,
        [{ "name": "Jeremy" }, "age"] => false,
        [{ "name": "Jeremy", "age": 41 }, "hobbies"] => false
      }
    },
    split: {
      description: "Splits a string based on a delimiter.",
      params: %w[string delimiter],
      tests: {
        ["Jeremy Walker", " "] => %w[Jeremy Walker],
        ["Jeremy", " "] => ["Jeremy"],
        %w[Jeremy r] => %w[Je emy]
      }
    },
    sort_string: {
      description: "Sorts a string alphabetically.",
      params: %w[unsorted],
      tests: {
        ["mostla"] => "almost",
        ["STOLMA"] => "ALMOST",
        ["illchy"] => "chilly",
        ["tap"] => "apt",
        ["PAT"] => "APT"
      }
    },
    join: {
      description: "Joins the strings in a list together, inserting a delimeter between them.",
      params: %w[things delimeter],
      tests: {
        [%w[Jeremy Walker], " "] => "Jeremy Walker",
        [%w[Jer my], "e"] => "Jeremy",
        [%w[Jer emy], ""] => "Jeremy",
        [["Jeremy"], "anything"] => "Jeremy",
        [[], ""] => ""
      }
    },
    capitalize: {
      description: "Capitalizes the first letter of a string.",
      params: %w[string],
      tests: {
        ["jeremy"] => "Jeremy",
        ["jeremy walker"] => "Jeremy walker",
        [""] => ""
      }
    },
    index_of: {
      description: "Find the index of an item in a list or string. If the item is missing, return -1.",
      params: %w[list target],
      tests: {
        [%w[Jeremy Walker], "Jeremy"] => 1,
        [%w[Jeremy Walker], "Walker"] => 2,
        [%w[Jeremy Walker], "Jiki"] => -1
      }
    },
    to_uppercase: {
      description: "Converts a string to uppercase.",
      params: %w[string],
      tests: {
        ["Jeremy"] => "JEREMY",
        ["Jeremy Walker"] => "JEREMY WALKER",
        [""] => ""
      }
    },
    to_lowercase: {
      description: "Converts a string to lowercase.",
      params: %w[string],
      tests: {
        ["Jeremy"] => "jeremy",
        ["JeReMy WaLkEr"] => "jeremy walker",
        [""] => ""
      }
    }
  }.freeze
end
