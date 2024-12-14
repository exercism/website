module Badges
  class UsainBoltBadge < Badge
    seed "Usain Bolt",
      :legendary,
      'usain-bolt',
      'Earned 48 gold medals in the #48in24 challenge'

    def award_to?(user)
      def exercises = User::Challenges::FeaturedExercisesProgress48In24.(user)
      exercises.all? {|e| e.status == :gold}
    end

    def send_email_on_acquisition? = true
  end
end
