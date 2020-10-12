module ViewComponents
  class Editor < ViewComponent
    def initialize(endpoint)
      @endpoint = endpoint
    end

    def to_s
      react_component("editor", { endpoint: endpoint })
    end

    private
    attr_reader :endpoint
  end
end
