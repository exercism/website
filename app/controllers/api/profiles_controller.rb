module API
  class ProfilesController < BaseController
    skip_before_action :authenticate_user!

    # TODO: Replace this with the real user's data
    def summary
      expires_in 1.minute
      render json: {
        id: 1,
        avatar_url: "https://avatars3.githubusercontent.com/u/135246?s=460&u=733b8575c8f0dbb5a52840c3efb2480b166c897a&v=4", # rubocop:disable Layout/LineLength
        name: "Erik ShireBOOM",
        handle: "ErikSchierboom",
        bio: "I am a developer with a passion for learning new languages. I love programming. I've done all the languages. I like the good languages the best.", # rubocop:disable Layout/LineLength
        location: "Bree, Middle Earth.",
        reputation: {
          total: 123,
          tooling: 240_683
        },
        badges: {
          count: 32,
          latest: %w[helpful thumbs-up]
        }
      }
    end
  end
end
