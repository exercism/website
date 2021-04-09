module ReactComponents
  module Profile
    class TestimonialSection < ReactComponent
      def to_s
        super("profile-testimonial-section", {
          handle: current_user.handle,
          num_testimonials: current_user.mentor_testimonials.count,
          num_solutions_mentored: 572,
          num_students_helped: 390,
          num_testimonials_received: 55,
          testimonials: [
            {
              text: "For the first time in my life, someone got my name right the first time round. "\
                "I’m not really sure what that means, but, I think I’m gonna go and celebrate. "\
                "Man, I can’t believe this. I can’t believe SleeplessByte got my name right!",
              student: {
                avatar_url: User.first.avatar_url,
                handle: "ErikShireBOOM"
              },
              exercise_title: "Lasagna",
              track_title: "C#"
            },
            {
              text: "Very much appreciate the challenge/hints regarding optional or more optimal solutions. Thanks!",
              student: {
                avatar_url: User.first.avatar_url,
                handle: "iHiD"
              },
              exercise_title: "Life",
              track_title: "Ruby"
            },
            {
              text: "let awesomeMentor: bool = match (Eric, Responsive, Helpful) with | 1, 1, 1 -> true",
              student: {
                avatar_url: User.first.avatar_url,
                handle: "neenjaw"
              },
              exercise_title: "Stuff",
              track_title: "Elixir"
            }
          ],
          links: {
            all: "#"
          }
        })
      end
    end
  end
end
