module ReactComponents
  module TrainingData
    class Dashboard < ReactComponent
      initialize_with :params, :statuses

      def to_s
        super("training-data-dashboard", {
          training_data_request:,
          tracks_request:,
          statuses:
        })
      end

      private
      def training_data_request
        {
          endpoint: 'endpoint to retrieve training data list',
          query: {
            status: params[:status] || DEFAULT_STATUS,
            criteria: params[:criteria],
            page: params[:page] ? params[:page].to_i : 1,
            track_slug: params[:track_slug]
          }.compact
        }
      end

      def tracks_request
        {
          endpoint: 'endpoint to retrieve tracks for filtering purposes',
          query: { status: params[:status] || DEFAULT_STATUS }
        }
      end

      DEFAULT_STATUS = :untagged
      private_constant :DEFAULT_STATUS
    end
  end
end
