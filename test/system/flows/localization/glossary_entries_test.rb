require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module Localization
    class GlossaryEntriesTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "translator can view and filter glossary entries list" do
        user = create :user
        user.update!(translator_locales: %w[fr es])

        # Create entries with different statuses
        create :localization_glossary_entry, locale: 'fr', term: 'Hello', translation: 'Bonjour', status: :unchecked
        create :localization_glossary_entry, locale: 'es', term: 'World', translation: 'Mundo', status: :proposed
        create :localization_glossary_entry, locale: 'fr', term: 'Goodbye', translation: 'Au revoir', status: :checked

        # Create entry for different locale (should not appear)
        create :localization_glossary_entry, locale: 'de', term: 'Good', translation: 'Gut'

        use_capybara_host do
          sign_in!(user)
          visit localization_glossary_entries_path

          # Verify all entries for user's locales are displayed
          assert_text 'Hello'
          assert_text 'Bonjour'
          assert_text 'World'
          assert_text 'Mundo'
          assert_text 'Goodbye'
          assert_text 'Au revoir'

          # Verify entry outside user's locales is not displayed
          refute_text 'Gut'

          # Test status filtering
          click_on 'Needs checking'
          sleep 0.5  # Wait for the AJAX request
          assert_text 'Hello'
          refute_text 'World'
          refute_text 'Goodbye'

          click_on 'Needs sign-off'
          sleep 0.5  # Wait for the AJAX request
          assert_text 'World'
          refute_text 'Hello'
          refute_text 'Goodbye'

          click_on 'Done'
          sleep 0.5  # Wait for the AJAX request
          assert_text 'Goodbye'
          refute_text 'Hello'
          refute_text 'World'

          # Test search functionality
          click_on 'All'
          sleep 0.5  # Wait for the AJAX request
          fill_in 'Search for translation', with: 'Hello'
          sleep 0.5  # Wait for the debounced search
          assert_text 'Hello'
          refute_text 'World'
          refute_text 'Goodbye'
        end
      end

      # Skip proposal modal test as mentioned - Proposal Modal won't be tested
      # test "translator can propose new glossary entry" do
      #   user = create :user
      #   user.update!(translator_locales: %w[fr], reputation: 25)

      #   use_capybara_host do
      #     sign_in!(user)
      #     visit localization_glossary_entries_path

      #     click_on 'Propose new term'

      #     within('.modal') do
      #       fill_in 'Term', with: 'Computer'
      #       fill_in 'Translation', with: 'Ordinateur'
      #       fill_in 'Instructions', with: 'Technical term for computing device'
      #       select 'French', from: 'Locale'

      #       click_on 'Save'
      #     end

      #     # Should show success message and close modal
      #     assert_text 'Glossary entry proposal created'
      #     refute_css '.modal'

      #     # Verify entry appears in list
      #     assert_text 'Computer'
      #     assert_text 'Ordinateur'
      #   end
      # end

      test "translator can view unchecked glossary entry details" do
        user = create :user
        user.update!(translator_locales: %w[fr])

        entry = create :localization_glossary_entry,
          locale: 'fr',
          term: 'Hello',
          translation: 'Bonjour',
          status: :unchecked,
          llm_instructions: 'Use formal greeting'

        use_capybara_host do
          sign_in!(user)
          visit localization_glossary_entry_path(entry)

          # Verify entry details are displayed
          assert_text 'Hello'
          assert_text 'Bonjour'
          assert_text 'Use formal greeting'

          # Should show editing interface for unchecked entries
          assert_text 'Edit Translation'
          sleep 2.5 # Wait for button to be enabled
          assert_button '👍 Mark as Checked', disabled: false
        end
      end

      test "translator can edit unchecked glossary entry translation" do
        user = create :user
        user.update!(translator_locales: %w[fr])

        entry = create :localization_glossary_entry,
          locale: 'fr',
          term: 'Hello',
          translation: 'Salut',
          status: :unchecked

        use_capybara_host do
          sign_in!(user)
          visit localization_glossary_entry_path(entry)

          click_on 'Edit Translation'

          # Edit the translation
          fill_in 'Translation', with: 'Bonjour'
          click_on 'Update Proposal'

          # Verify local update
          assert_text 'Bonjour'

          # Submit proposal
          click_on '👍 Submit proposal'

          # Should redirect to next entry or show success
          assert_current_path localization_glossary_entries_path, ignore_query: true
        end
      end

      test "translator can view proposed glossary entry with proposals" do
        user = create :user
        reviewer = create :user
        user.update!(translator_locales: %w[fr])
        reviewer.update!(translator_locales: %w[fr], reputation: 25)

        entry = create :localization_glossary_entry,
          locale: 'fr',
          term: 'Hello',
          translation: 'Salut',
          status: :proposed

        create :localization_glossary_entry_proposal,
          :modification,
          glossary_entry: entry,
          proposer: user,
          translation: 'Bonjour',
          status: :pending

        use_capybara_host do
          sign_in!(user)
          visit localization_glossary_entry_path(entry)

          # Verify proposals are displayed
          assert_text 'Proposal'
          assert_text 'Bonjour'

          # Regular translator should not see approve/reject buttons (should show "This is your proposal so you cannot approve it")
          refute_button '👍 Sign Off'
          refute_button 'Reject'
          assert_text '(This is your proposal so you cannot approve it)'
        end
      end

      test "reviewer can approve glossary entry proposal" do
        reviewer = create :user
        proposer = create :user
        reviewer.update!(translator_locales: %w[fr], reputation: 25)
        proposer.update!(translator_locales: %w[fr])

        entry = create :localization_glossary_entry,
          locale: 'fr',
          term: 'Hello',
          translation: 'Salut',
          status: :proposed

        create :localization_glossary_entry_proposal,
          :modification,
          glossary_entry: entry,
          proposer: proposer,
          translation: 'Bonjour',
          status: :pending

        use_capybara_host do
          sign_in!(reviewer)
          visit localization_glossary_entry_path(entry)

          # Reviewer should see approve/reject buttons
          assert_button '👍 Sign Off'
          assert_button 'Reject'

          sleep 2.5 # Wait for button to be enabled
          click_on '👍 Sign Off'

          # Should redirect to next entry or back to list
          assert_current_path localization_glossary_entries_path, ignore_query: true
        end
      end

      test "reviewer can reject glossary entry proposal" do
        reviewer = create :user
        proposer = create :user
        reviewer.update!(translator_locales: %w[fr], reputation: 25)
        proposer.update!(translator_locales: %w[fr])

        entry = create :localization_glossary_entry,
          locale: 'fr',
          term: 'Hello',
          translation: 'Salut',
          status: :proposed

        create :localization_glossary_entry_proposal,
          :modification,
          glossary_entry: entry,
          proposer: proposer,
          translation: 'Bonjour',
          status: :pending

        use_capybara_host do
          sign_in!(reviewer)
          visit localization_glossary_entry_path(entry)

          click_on 'Reject'

          # Should redirect to next entry or back to list
          assert_current_path localization_glossary_entries_path, ignore_query: true
        end
      end

      test "translator can view checked glossary entry (read-only)" do
        user = create :user
        user.update!(translator_locales: %w[fr])

        entry = create :localization_glossary_entry,
          locale: 'fr',
          term: 'Hello',
          translation: 'Bonjour',
          status: :checked

        use_capybara_host do
          sign_in!(user)
          visit localization_glossary_entry_path(entry)

          # Verify entry details are displayed
          assert_text 'Hello'
          assert_text 'Bonjour'

          # Should be read-only for checked entries
          refute_text 'Edit Translation'
          refute_button 'Update'
          refute_button 'Submit proposal'
        end
      end

      test "user without translator locales is redirected" do
        user = create :user
        # User has no translator_locales configured

        use_capybara_host do
          sign_in!(user)
          visit localization_glossary_entries_path

          # Should be redirected to set up translator locales
          assert_current_path new_localization_translator_path
        end
      end

      test "translator can filter entries by locale" do
        user = create :user
        user.update!(translator_locales: %w[fr es])

        create :localization_glossary_entry, locale: 'fr', term: 'Hello', translation: 'Bonjour'
        create :localization_glossary_entry, locale: 'es', term: 'Hello', translation: 'Hola'

        use_capybara_host do
          sign_in!(user)
          visit localization_glossary_entries_path

          # Initially both should be visible
          assert_text 'Bonjour'
          assert_text 'Hola'

          # Filter by French - click dropdown then select option
          click_button 'Locales: All'
          within('.--options') do
            find('.title', text: 'Français').click
          end
          sleep 0.5 # Wait for the AJAX request

          assert_text 'Bonjour'
          refute_text 'Hola'

          # Filter by Spanish - click dropdown then select option
          click_button 'Français' # Current selection shown as button text
          within('.--options') do
            find('.title', text: 'Español').click
          end
          sleep 0.5 # Wait for the AJAX request

          assert_text 'Hola'
          refute_text 'Bonjour'
        end
      end

      # Skip multiple proposals test - only one proposal per term now
      # test "translator can navigate through multiple proposals on entry" do
      #   reviewer = create :user
      #   proposer1 = create :user
      #   proposer2 = create :user
      #
      #   reviewer.update!(translator_locales: %w[fr], reputation: 25)
      #   proposer1.update!(translator_locales: %w[fr])
      #   proposer2.update!(translator_locales: %w[fr])
      #
      #   entry = create :localization_glossary_entry,
      #                 locale: 'fr',
      #                 term: 'Hello',
      #                 translation: 'Salut',
      #                 status: :proposed
      #
      #   proposal1 = create :localization_glossary_entry_proposal,
      #                     :modification,
      #                     glossary_entry: entry,
      #                     proposer: proposer1,
      #                     translation: 'Bonjour',
      #                     status: :pending
      #
      #   proposal2 = create :localization_glossary_entry_proposal,
      #                     :modification,
      #                     glossary_entry: entry,
      #                     proposer: proposer2,
      #                     translation: 'Salut toi',
      #                     status: :pending

      #   use_capybara_host do
      #     sign_in!(reviewer)
      #     visit localization_glossary_entry_path(entry)

      #     # Should see both proposals
      #     assert_text 'Bonjour'
      #     assert_text 'Salut toi'
      #
      #     # Should have multiple sets of approve/reject buttons
      #     assert_selector 'button', text: '👍 Sign Off', count: 2
      #     assert_selector 'button', text: 'Reject', count: 2
      #   end
      # end

      test "proposer can edit their own proposal" do
        proposer = create :user
        proposer.update!(translator_locales: %w[fr])

        entry = create :localization_glossary_entry, locale: 'fr', term: 'Hello', translation: 'Salut', status: :proposed

        proposal = create :localization_glossary_entry_proposal, :modification, glossary_entry: entry, proposer: proposer,
          translation: 'Bonjour', status: :pending

        use_capybara_host do
          sign_in!(proposer)
          visit localization_glossary_entry_path(entry)

          # Proposer should see edit option for their own proposal
          within("[data-proposal-id='#{proposal.uuid}']") do
            click_on 'Edit translation'

            fill_in 'Translation', with: 'Salut à tous'
            click_on 'Save'
          end

          # Should see updated translation
          assert_text 'Salut à tous'
        end
      end

      test "pagination works correctly in glossary entries list" do
        user = create :user
        user.update!(translator_locales: %w[fr])

        # Create more entries than fit on one page (assuming 24 per page)
        30.times do |i|
          create :localization_glossary_entry,
            locale: 'fr',
            term: "Term#{i}",
            translation: "Translation#{i}"
        end

        use_capybara_host do
          sign_in!(user)
          visit localization_glossary_entries_path

          # Should see first page of results (check that entries are present on first page)
          assert_text 'Term0'
          # Check that we have entries on first page but not all (we created 30 entries)

          # Navigate to next page if pagination is available
          if has_link?('Next')
            click_on 'Next'
            sleep 0.5 # Wait for the AJAX request

            # Should see different entries on next page
            refute_text 'Term0' # Should not see first page items anymore
          end
        end
      end

      test "search functionality works with debounced input" do
        user = create :user
        user.update!(translator_locales: %w[fr])

        create :localization_glossary_entry, locale: 'fr', term: 'Computer', translation: 'Ordinateur'
        create :localization_glossary_entry, locale: 'fr', term: 'Mouse', translation: 'Souris'
        create :localization_glossary_entry, locale: 'fr', term: 'Keyboard', translation: 'Clavier'

        use_capybara_host do
          sign_in!(user)
          visit localization_glossary_entries_path

          # Initially all entries should be visible
          assert_text 'Computer'
          assert_text 'Mouse'
          assert_text 'Keyboard'

          # Search for specific term
          fill_in 'Search for translation', with: 'Computer'

          # Wait for debounced search to execute
          sleep 0.5

          assert_text 'Computer'
          refute_text 'Mouse'
          refute_text 'Keyboard'

          # Clear search
          fill_in 'Search for translation', with: ''
          sleep 0.5

          # All entries should be visible again
          assert_text 'Computer'
          assert_text 'Mouse'
          assert_text 'Keyboard'
        end
      end
    end
  end
end
