module ReactComponents
  class ProgressGraph < ReactComponent
    initialize_with :data, :height, :width

    def to_s
      super(
        "progress-graph", {
          values: data,
          height: height,
          width: width
        }
      )
    end

    private
    attr_reader :data, :height, :width
  end
end
