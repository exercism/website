class TrainingData::CodeTagsSample::RetrieveNext
  include Mandate

  initialize_with :track, :filter_status do
    @filter_status = filter_status&.to_sym
    raise "Invalid 'filter_status' parameter" unless STATUSES.include?(@filter_status)
  end

  def call
    TrainingData::CodeTagsSample.unlocked.where(track:, status:).first
  end

  private
  def status
    case filter_status
    when :needs_tagging
      :untagged
    when :needs_checking
      %i[machine_tagged human_tagged]
    when :needs_checking_admin
      :community_checked
    end
  end

  STATUSES = %i[needs_tagging needs_checking needs_checking_admin].freeze
  private_constant :STATUSES
end
