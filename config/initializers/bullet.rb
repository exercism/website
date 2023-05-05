def Exercism.without_bullet
  Bullet.enable = false
  yield
ensure
  Bullet.enable = true

  # This is reset whenever enable is set
  # See https://github.com/flyerhzm/bullet/issues/481
  Bullet.unused_eager_loading_enable = false
  Bullet.counter_cache_enable = false
end

Rails.application.configure do
  config.after_initialize do
    Bullet.unused_eager_loading_enable = false
    Bullet.counter_cache_enable = false

    Bullet.add_safelist type: :n_plus_one_query, class_name: "User", association: :preferences
  end
end
