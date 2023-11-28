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
          }.compact,
          options: {
            initial_data:
          }
        }
      end

      def tracks
        ts = ::Track.where(id: ::TrainingData::CodeTagsSample.where(status: statuses_for_filter).select(:track_id))
        ts = ts.where(id: current_user.user_tracks.trainer.select(:track_id)) unless current_user.staff?
        AssembleTracksForSelect.(ts)
      end

      def filter_status = params[:status] || DEFAULT_STATUS
      def statuses_for_filter = ::TrainingData::CodeTagsSample.statuses_for_filter(filter_status.to_sym)
      def initial_data = AssembleCodeTagSamples.(params)

      DEFAULT_STATUS = :needs_tagging
      private_constant :DEFAULT_STATUS
    end
  end
end
