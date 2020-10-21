class Test::Components::Student::ConceptMapController < ApplicationController # rubocop:disable Layout/LineLength
  def show
    @data = {
      concepts: [
        {
          web_url: "basics-url",
          slug: "basics",
          name: "Basics"
        },
        {
          web_url: "booleans-url",
          slug: "booleans",
          name: "Booleans"
        },
        {
          web_url: "numbers-url",
          slug: "floating-point-numbers",
          name: "Floating Point Numbers"
        },
        {
          web_url: "numbers-url",
          slug: "integers",
          name: "Integer Numbers"
        },
        {
          web_url: "anonymous-fns-url",
          slug: "bit-manipulation",
          name: "Bit Manipulation"
        },
        {
          web_url: "anonymous-fns-url",
          slug: "closures",
          name: "Closures"
        },
        {
          web_url: "anonymous-fns-url",
          slug: "anonymous-functions",
          name: "Anonymous Functions"
        }
      ],
      levels: [
        ["basics"],
        %w[
          booleans
          integers
          floating-point-numbers
          anonymous-functions
          bit-manipulation
        ],
        ['closures']
      ],
      connections: [
        {
          from: "basics",
          to: "booleans"
        },
        {
          from: "basics",
          to: "integers"
        },
        {
          from: "basics",
          to: "floating-point-numbers"
        },
        {
          from: "basics",
          to: "anonymous-functions"
        },
        {
          from: "integers",
          to: "closures"
        },
        {
          from: "basics",
          to: "bit-manipulation"
        }
      ],
      status: {
        "basics" => :completed,
        "booleans" => :completed,
        "floating-point-numbers" => :unlocked,
        "integers" => :unlocked,
        "bit-manipulation" => :unlocked,
        "closures" => :locked,
        "anonymous-functions" => :unlocked
      }
    }
  end
end
