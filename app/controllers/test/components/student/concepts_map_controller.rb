class Test::Components::Student::ConceptsMapController < ApplicationController # rubocop:disable Layout/LineLength
  def show
    @data = {
      concepts: [
        {
          web_url: "basics-url",
          slug: "basics",
          name: "Basics",
          status: "completed"
        },
        {
          web_url: "booleans-url",
          slug: "booleans",
          name: "Booleans",
          status: "unlocked"
        },
        {
          web_url: "numbers-url",
          slug: "floating-point-numbers",
          name: "Floating Point Numbers",
          status: "completed"
        },
        {
          web_url: "numbers-url",
          slug: "integers",
          name: "Integer Numbers",
          status: "completed"
        },
        {
          web_url: "anonymous-fns-url",
          slug: "bit-manipulation",
          name: "Bit Manipulation",
          status: "unlocked"
        },
        {
          web_url: "anonymous-fns-url",
          slug: "closures",
          name: "Closures",
          status: "unlocked"
        },
        {
          web_url: "anonymous-fns-url",
          slug: "anonymous-functions",
          name: "Anonymous Functions",
          status: "unlocked"
        }
      ],
      layout: [
        ["basics"],
        %w[
          booleans
          integers
          floating-point-numbers
          anonymous-functions
          closures
          bit-manipulation
        ]
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
          from: "basics",
          to: "closures"
        },
        {
          from: "basics",
          to: "bit-manipulation"
        }
      ]
    }
  end
end
