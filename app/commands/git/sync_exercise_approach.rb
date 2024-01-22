class Git::SyncExerciseApproach
  include Mandate

  initialize_with :exercise, :config, :position

  def call
    find_or_create!.tap do |approach|
      approach.update!(attributes_for_update(approach))

      Exercise::Approach::LinkMatchingSubmissions.(approach) if approach.tags_previously_changed?
    end
  end

  private
  attr_reader :approach

  def find_or_create!
    Exercise::Approach.find_create_or_find_by!(uuid: config[:uuid]) do |approach|
      approach.attributes = attributes_for_create
    end
  end

  def attributes_for_create
    config.slice(:slug, :title, :blurb).
      merge({ exercise:, position:, synced_to_git_sha: exercise.git.head_sha })
  end

  def attributes_for_update(approach)
    attributes_for_create.merge({
      authorships: authorships(approach),
      contributorships: contributorships(approach),
      tags:
    })
  end

  def authorships(approach)
    ::User.with_data.where(data: { github_username: config[:authors].to_a }).
      map { |author| ::Exercise::Approach::Authorship::Create.(approach, author) }
  end

  def contributorships(approach)
    ::User.with_data.where(data: { github_username: config[:contributors].to_a }).
      map { |contributor| ::Exercise::Approach::Contributorship::Create.(approach, contributor) }
  end

  def tags
    return nil if config[:tags].blank?

    config[:tags].symbolize_keys.slice(:all, :any, :not)
  end
end
