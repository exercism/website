module ReactComponents
  module Common
    class MuxPlayer < ReactComponent
      initialize_with :playback_id, :title, :poster

      def to_s
        super("common-mux-player", { playback_id:, title:, poster: })
      end
    end
  end
end
