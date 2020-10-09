class Test::Components::Student::ConceptsMapController < ApplicationController # rubocop:disable Layout/LineLength
  def show
    @data = {
      concepts: [
        {
          index: 0,
          web_url: "basics-url",
          slug: "basics",
          status: "completed"
        },
        {
          index: 1,
          web_url: "booleans-url",
          slug: "booleans",
          status: "unlocked"
        },
        {
          index: 2,
          web_url: "numbers-url",
          slug: "floating-point-numbers",
          status: "completed"
        },
        {
          index: 3,
          web_url: "numbers-url",
          slug: "integers",
          status: "completed"
        },
        {
          index: 4,
          web_url: "anonymous-fns-url",
          slug: "bit-manipulation",
          status: "unlocked"
        },
        {
          index: 5,
          web_url: "anonymous-fns-url",
          slug: "closures",
          status: "unlocked"
        },
        {
          index: 6,
          web_url: "anonymous-fns-url",
          slug: "anonymous-functions",
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
