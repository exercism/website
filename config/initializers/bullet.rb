def Exercism.without_bullet
  Bullet.enable = false
  yield
ensure
  Bullet.enable = !Rails.env.production?

  # This is reset whenever enable is set
  # See https://github.com/flyerhzm/bullet/issues/481
  Bullet.unused_eager_loading_enable = false
  Bullet.counter_cache_enable = false
end

Rails.application.configure do
  config.after_initialize do
    Bullet.unused_eager_loading_enable = false
    Bullet.counter_cache_enable = false

    Bullet.add_safelist type: :n_plus_one_query, class_name: "User", association: :data
    Bullet.add_safelist type: :n_plus_one_query, class_name: "User", association: :preferences
    Bullet.add_safelist type: :n_plus_one_query, class_name: "User::Data", association: :user
  end
end
