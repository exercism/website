class SitemapsController < ApplicationController
  skip_before_action :authenticate_user!

  around_action do |_, action|
    ActiveRecord::Base.transaction(isolation: Exercism::READ_COMMITTED) do
      action.()
    end
  end

  def robots_txt
    render html: "User-agent: * Allow: /"
  end

  def index
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.sitemapindex(xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9") do
        xml.sitemap { xml.loc sitemap_general_url(format: :xml) }
        xml.sitemap { xml.loc sitemap_profiles_url(format: :xml) }
        Track.active.order('num_concepts DESC, num_exercises DESC').each do |track|
          xml.sitemap do
            xml.loc sitemap_track_url(track, format: :xml)
          end
        end
      end
    end
    render xml: builder.to_xml
  end

  def general
    pages = [
      [root_url, Date.new(2022, 3, 1), :monthly, 1],
      [tracks_url, Track.pluck(:updated_at).last, :monthly, 1],
      [docs_url, Date.new(2022, 3, 1), :monthly, 0.95],

      [about_url, Date.new(2022, 3, 1), :monthly, 0.95],
      [team_about_url, Date.new(2022, 3, 1), :monthly, 0.9],
      [hiring_about_url, Date.new(2022, 3, 1), :monthly, 0.7],
      [about_partners_url, Date.new(2022, 3, 1), :monthly, 0.9],
      [individual_supporters_about_url, Date.new(2022, 3, 1), :monthly, 0.9],

      [contributing_root_url, Date.new(2022, 3, 1), :monthly, 0.9],
      [contributing_tasks_url, Date.new(2022, 3, 1), :daily, 0.7],
      [contributing_contributors_url, Date.new(2022, 3, 1), :daily, 0.7],
      [mentoring_url, Date.new(2022, 3, 1), :monthly, 0.9],
      [donate_url, Date.new(2022, 3, 1), :monthly, 0.9],

      [blog_posts_url, BlogPost.published.pluck(:updated_at).last, :monthly, 0.95]
    ]

    BlogPost.published.ordered_by_recency.each do |blog_post|
      pages << [blog_post_url(blog_post), blog_post.updated_at, :monthly, 0.75]
    end

    Document.where(track: nil).each do |doc|
      pages << [doc_url(doc.section, doc.slug), doc.updated_at, :monthly, 0.75]
    end

    render xml: pages_to_xml(pages)
  end

  def profiles
    pages = []
    User::Profile.joins(:user).where('users.reputation >= 200').includes(:user).find_each do |profile|
      user = profile.user

      priority = 0 + [0.75, user.reputation / 10_000.0].min
      pages << [profile_url(user), user.updated_at, :monthly, priority]
      # pages << [solutions_profile_url(user), user.updated_at, :monthly, priority - 0.01] if profile.solutions_tab?
      pages << [testimonials_profile_url(user), user.updated_at, :monthly, priority - 0.01] if profile.testimonials_tab?
      # pages << [contributions_profile_url(user), user.updated_at, :monthly, priority - 0.01] if profile.contributions_tab?
    end

    render xml: pages_to_xml(pages)
  end

  def track
    track = Track.find(params[:track_id])
    pages = []
    pages << [track_url(track), track.updated_at, :monthly, 0.9]
    pages << [track_concepts_url(track), track.updated_at, :monthly, 0.85] if track.course?
    pages << [track_exercises_url(track), track.updated_at, :monthly, 0.85]

    if track.course?
      track.concepts.each do |concept|
        pages << [track_concept_url(track, concept), concept.updated_at, :monthly, 0.8]
      end
    end

    pages << [track_docs_url(track.slug), track.updated_at, :monthly, 0.8]
    track.documents.each do |doc|
      pages << [track_doc_url(track.slug, doc.slug), doc.updated_at, :monthly, 0.75]
    end

    track.exercises.active.each do |exercise|
      pages << [track_exercise_url(track, exercise), exercise.updated_at, :monthly, 0.75]
      pages << [track_exercise_solutions_url(track, exercise), Time.zone.today, :daily, 0.7]

      exercise.solutions.published.where('num_stars > 0').order(num_stars: :desc).limit(100).includes(:track, :exercise,
        :user).each do |solution|
        priority = 0.5 + [0.1, solution.num_stars / 100.0].min
        pages << [Exercism::Routes.published_solution_url(solution), solution.updated_at, :monthly, priority]
      end

      if exercise.has_approaches? # rubocop:disable Style/Next
        pages << [track_exercise_dig_deeper_path(track, exercise), exercise.updated_at, :monthly, 0.75]

        exercise.approaches.each do |approach|
          pages << [track_exercise_approach_path(track, exercise, approach), approach.updated_at, :monthly, 0.75]
        end

        exercise.articles.each do |article|
          pages << [track_exercise_article_path(track, exercise, article), article.updated_at, :monthly, 0.75]
        end
      end
    end

    render xml: pages_to_xml(pages)
  end

  private
  def pages_to_xml(pages)
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.urlset(xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9") do
        pages.each do |page|
          xml.url do
            xml.loc page[0]
            xml.lastmod page[1].xmlschema
            xml.changefreq page[2]
            xml.priority page[3]
          end
        end
      end
    end
    builder.to_xml
  end
end
