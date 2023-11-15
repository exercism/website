class TrainingData::CodeTagsSample::Retrieve
  include Mandate

  initialize_with :status, track: nil, criteria: nil, dataset: :training, page: 1 do
    raise "The 'status' parameter must not be nil or empty" if status.blank?
  end

  SAMPLES_PER_PAGE = 10

  def self.samples_per_page = SAMPLES_PER_PAGE

  def call
    setup!
    filter_dataset!
    filter_status!
    filter_track!
    filter_criteria!
    paginate!

    @samples
  end

  private
  def setup!
    @samples = TrainingData::CodeTagsSample.includes(:exercise, :track)
  end

  def filter_dataset!
    return if dataset.blank?

    @samples = @samples.where(dataset:)
  end

  def filter_status!
    return if status.blank?

    @samples = @samples.where(status:)
  end

  def filter_track!
    return if track.blank?

    @samples = @samples.where(track:)
  end

  def filter_criteria!
    return if criteria.blank?

    @samples = @samples.joins(:exercise).where("exercises.title LIKE ?", "%#{criteria}%")
  end

  def paginate!
    @samples = @samples.page(page).per(self.class.samples_per_page)
  end
end
