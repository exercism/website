class AddProfilePublishedSolutionsIndexToSolutions < ActiveRecord::Migration[7.1]
  def change
    return if Rails.env.production?

    # ProfilesController#show wants a user's top 3 published solutions by
    # num_stars. index_solutions_on_user_id_and_status covers the filter but
    # not the sort, so MySQL filesorted every published solution the user had
    # to pick 3. Our worst user has 209,884 of them.
    #
    # Column order is the whole point. user_id and status are equality, which
    # leaves num_stars and updated_at pre-sorted within that run, so the query
    # is a backward index scan that stops after 3 rows (78us on that user).
    # The existing (user_id, status, exercise_id) index can't do this: a third
    # column of exercise_id orders the run by something we don't sort on.
    #
    # Mirrors solutions_ex_stat_stars_upat, which is the same index keyed on
    # exercise_id for the per-exercise community solutions list.
    #
    # Already created manually on production, hence if_not_exists.
    add_index :solutions, %i[user_id status num_stars updated_at],
      name: "index_solutions_profile_published_by_stars",
      if_not_exists: true
  end
end
