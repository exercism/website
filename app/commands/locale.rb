module Locale
  # Records a locale the visitor chose, as opposed to one we inferred from
  # Accept-Language. It exists only once they have used the switcher or the
  # banner, so its presence is the signal that a guess must not override them.
  PREF_COOKIE_NAME = :_exercism_locale_pref
end
