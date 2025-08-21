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
        %w[rubber rubber] => true,
        %w[rubber rub] => true,
        %w[rubber r] => true,
        ["", ""] => true,
        %w[rubber duck] => false,
        ["rubber", "rubber duck"] => false
      }
    },
    length: {
      description: "Returns the length of a string or list.",
      params: ["measurable"],
      tests: {
        ["duck"] => 4,
        [["duck", 1, false]] => 3,
        [""] => 0,
        [[]] => 0
      }
    },
    contains: {
      description: "Returns a boolean informing you of whether a list contains an element, or a string contains a character.",
      params: %w[haystack needle],
      tests: {
        %w[rubber r] => true,
        %w[rubber b] => true,
        %w[rubber a] => false,
        ["rubber duck", " "] => true,
        ["rubber duck", "d"] => true,
        ["rubber duck", "a"] => false,
        [["rd", 1, false], "rd"] => true,
        [["rd", 1, false], 1] => true,
        [["rd", 1, false], false] => true,
        [["rd", 1, false], "foo"] => false
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
        ["Rubber Duck", " "] => %w[Rubber Duck],
        ["Rubber", " "] => ["Rubber"],
        %w[Rubber e] => %w[Rubb r]
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
      description: "Joins the strings in a list together, inserting a delimiter between them.",
      params: %w[things delimiter],
      tests: {
        [%w[Rubber Duck], " "] => "Rubber Duck",
        [%w[Rub er], "b"] => "Rubber",
        [%w[Rub ber], ""] => "Rubber",
        [["Rubber"], "duck"] => "Rubber",
        [[], ""] => ""
      }
    },
    capitalize: {
      description: "Capitalizes the first letter of a string.",
      params: %w[string],
      tests: {
        ["rubber"] => "Rubber",
        ["rubber duck"] => "Rubber duck",
        [""] => ""
      }
    },
    index_of: {
      description: "Find the index of an item in a list or string. If the item is missing, return -1.",
      params: %w[list target],
      tests: {
        [%w[Rubber Duck], "Rubber"] => 1,
        [%w[Rubber Duck], "Duck"] => 2,
        [%w[Rubber Duck], "Jiki"] => -1
      }
    },
    to_uppercase: {
      description: "Converts a string to uppercase.",
      params: %w[string],
      tests: {
        ["rubber"] => "RUBBER",
        ["Rubber"] => "RUBBER",
        ["RUBBER"] => "RUBBER",
        ["Rubber Duck"] => "RUBBER DUCK",
        [""] => ""
      }
    },
    to_lowercase: {
      description: "Converts a string to lowercase.",
      params: %w[string],
      tests: {
        ["rubber"] => "rubber",
        ["Rubber"] => "rubber",
        ["RUBBER"] => "rubber",
        ["Rubber Duck"] => "rubber duck",
        [""] => ""
      }
    },
    to_unique: {
      description: "Returns a list with all the duplicates removed.",
      params: %w[list],
      tests: {
        [%w[rubber duck rubber]] => %w[rubber duck],
        [%w[duck rubber rubber duck duck rubber]] => %w[duck rubber],
        [["rubber"]] => ["rubber"],
        [[]] => []
      }
    },
    char_code: {
      description: "Return the character code of a latin letter, number or full-stop. Use the tests to work out the values.",
      params: %w[char],
      tests: {
        ["A"] => 65,
        ["J"] => 74,
        ["Z"] => 90,
        ["a"] => 97,
        ["j"] => 106,
        ["z"] => 122,
        [" "] => 32,
        ["0"] => 48,
        ["9"] => 57
      }
    },
    is_alpha: {
      description: "Returns true if a string contains only letters, false otherwise.",
      params: %w[string],
      tests: {
        ["Rubber"] => true,
        ["Duck"] => true,
        ["Rubber Duck"] => false,
        ["123"] => false
      }
    },
    is_numeric: {
      description: "Returns true if a string contains only numbers, false otherwise.",
      params: %w[string],
      tests: {
        ["123"] => true,
        ["456"] => true,
        ["123 456"] => false,
        ["Rubber Duck"] => false
      }
    },
    is_alphanumeric: {
      description: "Returns true if a string contains only letters and numbers, false otherwise.",
      params: %w[string],
      tests: {
        ["Rubber"] => true,
        ["42"] => true,
        ["RubberDuck42"] => true,
        ["Rubber Duck"] => false,
        ["123 456"] => false
      }
    },
    number_to_string: {
      description: "Takes a number and returns it as a string.",
      params: %w[number],
      tests: {
        [1] => "1",
        [12] => "12",
        [123] => "123",
        [1_234_567_890] => "1234567890",
        [9_876_543_210] => "9876543210"
      }
    }
  }.freeze
end
