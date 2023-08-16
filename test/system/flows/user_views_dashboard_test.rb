require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class UserViewsDashboardTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "shows last touched tracks" do
      user = create :user
      nim = create :track, slug: "nim", title: "Nim"
      ruby = create :track, slug: "ruby", title: "Ruby"
      kotlin = create :track, slug: "kotlin", title: "Kotlin"
      elixir = create :track, slug: "elixir", title: "Elixir"
      create :user_track, track: nim, user:, last_touched_at: 4.days.ago
      create :user_track, track: kotlin, user:, last_touched_at: 3.days.ago
      create :user_track, track: ruby, user:, last_touched_at: 2.days.ago
      create :user_track, track: elixir, user:, last_touched_at: 1.day.ago

      use_capybara_host do
        sign_in!(user)
        visit dashboard_path

        within(".tracks-section .tracks") do
          assert_selector('.track', count: 3)

          expected_order = %w[Elixir Ruby Kotlin]
          find_all(".track .info .title").map.with_index do |_track, i|
            assert_text expected_order[i]
          end
        end
      end
    end

    test "shows latest revealed badges" do
      user = create :user

      %i[member rookie begetter researcher moss contributor architect].each do |badge_name|
        badge = create("#{badge_name}_badge".to_sym)
        create :user_acquired_badge, user:, badge:, revealed: true
      end

      # Ignore latest unrevealed badges
      create :user_acquired_badge, user:, badge: create(:lackadaisical_badge), revealed: false
      create :user_acquired_badge, user:, badge: create(:whatever_badge), revealed: false

      use_capybara_host do
        sign_in!(user)
        visit dashboard_path

        within(".badges") do
          assert_selector('.c-badge-medallion', count: 4)
          assert_text "+ 3 more"

          expected_order = %w[researcher moss contributor architect]
          find_all("c-badge-medallion --legendary").map.with_index do |_, i|
            assert_selector("img[alt*='#{expected_order[i]}']")
          end
        end
      end
    end

    test "shows latest site updates for joined tracks" do
      user = create :user
      joined_track = create :track, slug: 'ruby'
      unjoined_track = create :track, slug: 'kotlin'
      create :user_track, user:, track: joined_track
      joined_arbitrary_update = create :arbitrary_site_update, title: "Arbitrary update 1",
        description_markdown: 'Such a cool update', track: joined_track, published_at: Time.current
      joined_concept_update = create :new_concept_site_update, track: joined_track,
        params: { concept: create(:concept, track: joined_track) }, published_at: Time.current
      joined_concept_exercise_update = create :new_exercise_site_update, track: joined_track,
        exercise: create(:concept_exercise, :random_slug, track: joined_track), published_at: Time.current
      joined_practice_exercise_update = create :new_exercise_site_update, track: joined_track,
        exercise: create(:concept_exercise, :random_slug, track: joined_track), published_at: Time.current

      # Sanity check: don't show updates for unjoined track
      unjoined_arbitrary_update = create :arbitrary_site_update, title: "Arbitrary update 2",
        description_markdown: 'Another cool update', track: unjoined_track, published_at: Time.current
      unjoined_concept_update = create :new_concept_site_update, track: unjoined_track,
        params: { concept: create(:concept, track: unjoined_track) }, published_at: Time.current
      unjoined_concept_exercise_update = create :new_exercise_site_update, track: unjoined_track,
        exercise: create(:practice_exercise, :random_slug, track: unjoined_track), published_at: Time.current
      unjoined_practice_exercise_update = create :new_exercise_site_update, track: unjoined_track,
        exercise: create(:practice_exercise, :random_slug, track: unjoined_track), published_at: Time.current

      # Sanity check: don't show unpublished updates
      unpublished_exercise_update = create :new_exercise_site_update, track: joined_track,
        exercise: create(:concept_exercise, :random_slug, track: joined_track), published_at: nil

      use_capybara_host do
        sign_in!(user)
        visit dashboard_path

        within(".activity-section") do
          assert_text joined_arbitrary_update.title
          assert_text "We published a new Concept: #{joined_concept_update.concept.name}"
          assert_text "We published a new Exercise: #{joined_concept_exercise_update.exercise.title}"
          assert_text "We published a new Exercise: #{joined_practice_exercise_update.exercise.title}"

          refute_text unjoined_arbitrary_update.title
          refute_text "We published a new Concept: #{unjoined_concept_update.concept.name}"
          refute_text "We published a new Exercise: #{unjoined_concept_exercise_update.exercise.title}"
          refute_text "We published a new Exercise: #{unjoined_practice_exercise_update.exercise.title}"
          refute_text "We published a new Exercise: #{unpublished_exercise_update.exercise.title}"
        end
      end
    end
  end
end
