class Test::Components::Tooltips::TooltipController < Test::BaseController
  def show; end

  def user_summary
    return head :internal_server_error if params[:state] == "Error" || params[:state] == "Loading"

    users = [
      {
        id: 1,
        avatar_url: "https://robohash.org/exercism",
        name: "Erik Schierboom",
        handle: "ErikSchierboom",
        bio: "I am a developer with a passion for learning new languages. C# is a well-designed and expressive language that I love programming in.", # rubocop:disable Layout/LineLength
        location: "Arnhem, The Netherlands",
        reputation: {
          total: 300_000,
          tooling: 240_683
        },
        badges: {
          count: 32,
          latest: %w[helpful thumbs-up]
        }
      },
      {
        id: 2,
        avatar_url: "https://robohash.org/exercism_2",
        name: "Rob Keim",
        handle: "robkeim",
        bio: "I stumbled upon this site when I was trying to learn about functional programming and F#. Little did I know, I'd wind up becoming a contributor and learning a whole lot more than what I originally intended to. I had never contributed to an open source project before, and it's been a very rewarding experience.", # rubocop:disable Layout/LineLength
        reputation: {
          total: 16_000,
          tooling: 15_678
        },
        badges: {
          count: 3,
          latest: ["old-school"]
        }
      }
    ]

    user = users.detect { |s| s[:id] == params[:id].to_i }

    expires_in 1.minute
    render json: user
  end
end
