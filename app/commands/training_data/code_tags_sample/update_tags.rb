class TrainingData::CodeTagsSample::UpdateTags
  include Mandate

  initialize_with :sample, :tags, :user

  def call
    ActiveRecord::Base.transaction do
      sample.lock!

      raise TrainingDataCodeTagsSampleLockedByAnotherUserError unless sample.lockable_by?(user)

      sample.update!(tags:, status: new_status, locked_until: nil, locked_by: nil)
    end
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
