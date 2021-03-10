# This is a serializer for the mentor discussion in the context of the mentoring session
# TODO: Name this better?

class SerializeMentorDiscussion
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

  def links
    if discussion.mentor == user
      {
        posts: Exercism::Routes.api_mentoring_discussion_posts_url(discussion),
        mark_as_nothing_to_do: (
          if discussion.requires_mentor_action?
            Exercism::Routes.mark_as_nothing_to_do_api_mentoring_discussion_path(discussion)
          end
        ),
        finish: (
          Exercism::Routes.finish_api_mentoring_discussion_path(discussion) unless discussion.finished?
        )
      }.compact
    else
      {
        posts: Exercism::Routes.api_mentoring_discussion_posts_url(discussion)
      }
    end
  end
end
