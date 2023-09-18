module UserTracksHelper
  def user_track_completed_percentage_text(user_track)
    case user_track.completed_percentage
    when 0...10
      "Keep up the good work! 🚀"
    when 10...20
      "That's a great start! 🚀"
    when 20...30
      "Picking up speed now! 🚀"
    when 30...40
      "You're really getting somewhere! 🚀"
    when 40...50
      "Nearly halfway! 🚀"
    when 50...60
      "Over halfway there! 🚀"
    when 60...70
      "At this rate, you'll complete it! 🚀"
    when 70...80
      "Wow - keep going! 🚀"
    when 80...90
      "Getting really close! 🚀"
    when 90...100
      "Can see the finish line now! 🚀"
    else
      "Invalid percentage."
    end
  end
end
