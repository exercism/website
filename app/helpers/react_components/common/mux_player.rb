module ReactComponents
  module Common
    class MuxPlayer < ReactComponent
      initialize_with :playback_id, :title

      def to_s
        super("common-mux-player", { playback_id:, title: })
      end
    end
  end
end
