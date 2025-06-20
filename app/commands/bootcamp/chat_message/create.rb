class Bootcamp::ChatMessage
  class Create
    include Mandate

    initialize_with :solution, :content, :author

    def call
      Bootcamp::ChatMessage.create!(
        solution:,
        content:,
        author:
      )
    end
  end
end
