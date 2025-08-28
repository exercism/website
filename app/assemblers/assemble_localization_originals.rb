class AssembleLocalizationOriginals
  include Mandate

  initialize_with :user, :params

  def self.keys
    %i[criteria status page]
  end

  def call
    SerializePaginatedCollection.(
      translations,
      serializer: SerializeLocalizationOriginals,
      serializer_args: user,
      meta: {
        unscoped_total: Localization::Original.count
      }
    )
  end

  memoize
  def translations
    Localization::Original::Search.(
      user,
      criteria: params[:criteria],
      status: params[:status],
      page: params[:page]
    )
  end
end
