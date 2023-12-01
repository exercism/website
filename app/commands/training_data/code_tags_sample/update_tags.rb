class TrainingData::CodeTagsSample::UpdateTags
  include Mandate

  initialize_with :sample, :tags, :status, :user

  def call
    sample.with_lock do
      sample.lock_for_editing!(user)
      sample.update!(
        tags: TrainingData::CodeTagsSample::NormalizeTags.(tags),
        status:,
        community_checked_by:,
        admin_checked_by:
      )
      sample.unlock!
    end
  end

  private
  def community_checked_by
    return user if status == :community_checked

    sample.community_checked_by
  end

  def admin_checked_by
    return user if status == :admin_checked

    sample.admin_checked_by
  end
end
