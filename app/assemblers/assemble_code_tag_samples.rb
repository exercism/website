class AssembleCodeTagSamples
  include Mandate

  initialize_with :params

  def call
    SerializePaginatedCollection.(
      samples,
      serializer: SerializeCodeTagsSamples,
      serializer_kwargs: { status: }
    )
  end

  private
  def samples
    TrainingData::CodeTagsSample::Retrieve.(
      status,
      criteria: params[:criteria],
      track:,
      page:
    )
  end

  def track = params[:track_slug].present? && Track.find(params[:track_slug])
  def status = params.fetch(:status, :needs_tagging).to_sym
  def page = [params[:page].to_i, 1].max
end
