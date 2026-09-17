// A language's name, by default in that language itself ("Magyar"),
// which is how a language picker should list it.
export function nameForLocale(
  locale: string,
  options: { displayInEnglish?: boolean } = {}
): string {
  const displayLocale = options.displayInEnglish ? 'en' : locale

  try {
    const name = new Intl.DisplayNames([displayLocale], {
      type: 'language',
    }).of(locale)
    if (!name) return locale

    // Many languages write their own name in lowercase ("magyar", "español")
    return name.charAt(0).toLocaleUpperCase(displayLocale) + name.slice(1)
  } catch {
    return locale
  }
}
