class Community::InterviewsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @language_creator_ids = [
      "RIKx1sEkVFY", # C++ (Bjarne)
      "fBFsxmJEk7M", # Haskell (Simon)

      "G7vqoR431Zo", # Gleam (Louis)
      "DhxijTyxSk0", # Go (Cameron)
      "LknqlTouTKg", # Elixir (Jose)
      "Q3sLSihQ0vw" # Rust (Josh)
    ]

    @stories = CommunityStory.all
  end
end
