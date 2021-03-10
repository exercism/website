class SerializeMentorSessionDiscussion
  include Mandate

  initialize_with :discussion, :user

  def call
    return if discussion.blank?

    {
      id: discussion.uuid,
      is_finished: discussion.finished?,
      links: links
    }
  end

  private
  delegate :mentor, to: :discussion

  def links
    {
      posts: Exercism::Routes.api_mentoring_discussion_posts_url(discussion)
    }.tap do |links|
      if user == mentor
        links[:finish] = Exercism::Routes.finish_api_mentoring_discussion_path(discussion) unless discussion.finished?

        if discussion.requires_mentor_action?
          links[:mark_as_nothing_to_do] = Exercism::Routes.mark_as_nothing_to_do_api_mentoring_discussion_path(discussion)
        end
      end
    end
  end
end
