class TrainingData::CodeTagsSample::Retrieve
  include Mandate

  initialize_with :status, track: nil, criteria: nil, dataset: :training, page: 1 do
    @status = status&.to_sym
    raise "Invalid 'status' parameter" unless STATUSES.include?(@status)
  end

  def self.samples_per_page = SAMPLES_PER_PAGE

  def call
    setup!
    filter_status!
    filter_dataset!
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

    case status
    when :needs_tagging
      @samples = @samples.where(status: :untagged)
    when :needs_checking
      @samples = @samples.where(status: %i[machine_tagged human_tagged])
    when :needs_checking_admin
      @samples = @samples.where(status: %i[community_checked])
    end
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

  SAMPLES_PER_PAGE = 20
  STATUSES = %i[needs_tagging needs_checking needs_checking_admin].freeze
  private_constant :SAMPLES_PER_PAGE, :STATUSES
end
