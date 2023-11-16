module ReactComponents
  module TrainingData
    class Dashboard < ReactComponent
      initialize_with :params, :statuses

      def to_s
        super("training-data-dashboard", {
          training_data_request:,
          statuses:,
          tracks:
        })
      end

      private
      def training_data_request
        {
          endpoint: Exercism::Routes.api_training_data_code_tags_samples_url,
          query: {
            status: params[:status] || DEFAULT_STATUS,
            criteria: params[:criteria],
            page: params[:page] ? params[:page].to_i : 1,
            track_slug: params[:track_slug]
          }.compact
        }
      end

      def tracks
        # TODO: optimize this
        track_ids = User::ReputationPeriod.
          where(period: :forever, about: :track, user: current_user).
          group(:track_id).
          sum(:reputation).
          select { |_, reputation| reputation >= User::MIN_REP_TO_TRAIN_ML }.
          keys

        AssembleTracksForSelect.(::Track.where(id: track_ids))
      end

      DEFAULT_STATUS = :needs_tagging
      private_constant :DEFAULT_STATUS
    end
  end
end
