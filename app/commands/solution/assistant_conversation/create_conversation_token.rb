class Solution::AssistantConversation::CreateConversationToken
  include Mandate

  TOKEN_LIFETIME = 1.hour

  initialize_with :solution

  def call
    unless Solution::AssistantConversation::CheckUserAccess.(solution)
      raise AssistantConversationAccessDeniedError, "Assistant access is not allowed for this solution"
    end

    Solution::AssistantConversation::FindOrCreate.(solution)

    JWT.encode(payload, Exercism.secrets.assistant_chat_jwt_secret, 'HS256')
  end

  private
  def payload
    {
      sub: solution.user_id,
      solution_uuid: solution.uuid,
      track_slug: solution.track.slug,
      exercise_slug: solution.exercise.slug,
      exp: TOKEN_LIFETIME.from_now.to_i,
      iat: Time.current.to_i
    }
  end
end
