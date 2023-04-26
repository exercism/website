def Exercism.without_bullet
  return yield unless defined?(Bullet)

  begin
    Bullet.enable = false
    yield
  ensure
    Bullet.enable = true
  end
end

return unless defined?(Bullet)

Rails.application.configure do
  config.after_initialize do
    Bullet.unused_eager_loading_enable = false

    Bullet.add_safelist type: :n_plus_one_query, class_name: "Submission", association: :exercise_representation
  end
end
