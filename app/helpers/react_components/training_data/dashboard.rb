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
            status: filter_status,
            criteria: params[:criteria],
            page: params[:page] ? params[:page].to_i : 1,
            track_slug: params[:track_slug]
          }.compact
        }
      end

      def tracks
        ts = ::Track.where(id: ::TrainingData::CodeTagsSample.where(status: sample_status).select(:track_id))
        ts = ts.where(id: current_user.user_tracks.trainer.select(:track_id)) unless current_user.staff?
        AssembleTracksForSelect.(ts)
      end

      def filter_status = params[:status] || DEFAULT_STATUS
      def sample_status = ::TrainingData::CodeTagsSample.sample_status(filter_status.to_sym)

      DEFAULT_STATUS = :needs_tagging
      private_constant :DEFAULT_STATUS
    end
  end
end
