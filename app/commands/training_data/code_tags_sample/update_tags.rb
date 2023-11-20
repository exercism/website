class TrainingData::CodeTagsSample::UpdateTags
  include Mandate

  initialize_with :sample, :tags

  def call
    sample.update!(tags:, status: new_status)
  end

  private
  def new_status
    case sample.status
    when :untagged
      :human_tagged
    when :machine_tagged
      :community_checked
    when :human_tagged
      :community_checked
    when :community_checked
      :admin_checked
    else
      sample.status
    end
  end
end
