module Badges
  class MossBadge < Badge
    seed "Moss",
      :legendary,
      'moss',
      'Provided support to new users'

    def award_to?(user)
      return false unless user.github_username

      SUPPORTERS.include?(user.github_username.downcase)
    end

    def send_email_on_acquisition? = true

    SUPPORTERS = %w[
      andrerfcsantos
      bethanyg
      bobahop
      erikschierboom
      glennj
      ihid
      isaacg
      jimpjorps
      kotp
      meatball
      nobbz
      sleeplessbyte
      vaeng
      ynfle
    ].freeze
    private_constant :SUPPORTERS
  end
end
