require 'application_system_test_case'
require_relative '../../../support/capybara_helpers'

module Flows
  module Maintainer
    class MaintainerAddsArbitrarySiteUpdateTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test 'maintainer adds arbitrary site update' do
        maintainer = create :user, :maintainer, uid: '136131'
        maintainer.dismiss_introducer!('welcome-modal')
        track = create :track, slug: 'fsharp', repo_url: 'exercism/fsharp'
        create(:user_track, user: maintainer, track:)
        create :github_team_member, team_name: track.github_team_name, user_id: maintainer.uid
        pr = create :github_pull_request, repo: track.repo_url

        use_capybara_host do
          sign_in!(maintainer)

          visit maintaining_site_updates_path
          click_on 'New site update'

          fill_in 'Title', with: 'F# track now supports .NET 7'
          fill_in 'Description', with: 'The F# has added support for the _lovely_ .NET 7'
          select track.title, from: 'site_update_track_id'
          fill_in 'Pull Request number (https://github.com/exercism/<repo>/pull/<number>)', with: pr.number
          click_on 'Create Site Update'

          assert_text 'F# track now supports .NET 7'
        end
      end
    end
  end
end
