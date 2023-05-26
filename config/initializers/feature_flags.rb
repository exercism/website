module FeatureFlag
  PREMIUM = !Rails.env.production?
end
