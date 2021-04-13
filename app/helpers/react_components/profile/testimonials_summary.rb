module ReactComponents
  module Profile
    class TestimonialsSummary < ReactComponent
      def initialize(user)
        @user = user

        super()
      end

      def to_s
        super("profile-testimonials-summary", {
          handle: user.handle,
          num_testimonials: user.mentor_testimonials.count,
          num_solutions_mentored: 572,
          num_students_helped: 390,
          num_testimonials_received: 55,
          testimonials: [
            {
              content: "For the first time in my life, someone got my name right the first time round. "\
                "I’m not really sure what that means, but, I think I’m gonna go and celebrate. "\
                "Man, I can’t believe this. I can’t believe SleeplessByte got my name right!",
              student: {
                avatar_url: User.first.avatar_url,
                handle: "ErikShireBOOM"
              },
              exercise: {
                title: "Lasagna"
              },
              track: {
                title: "C#"
              }
            },
            {
              content: "Very much appreciate the challenge/hints regarding optional or more optimal solutions. Thanks!",
              student: {
                avatar_url: User.first.avatar_url,
                handle: "iHiD"
              },
              exercise: {
                title: "Life"
              },
              track: {
                title: "Ruby"
              }
            },
            {
              content: "let awesomeMentor: bool = match (Eric, Responsive, Helpful) with | 1, 1, 1 -> true",
              student: {
                avatar_url: User.first.avatar_url,
                handle: "neenjaw"
              },
              exercise: {
                title: "Stuff"
              },
              track: {
                title: "Elixir"
              }
            }
          ],
          links: {
            all: "#"
          }
        })
      end

      private
      attr_reader :user
    end
  end
end
