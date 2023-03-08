class Mailshot
  class Send
    include Mandate

    initialize_with :mailshot, :audience_type, :audience_slug
  end
end
