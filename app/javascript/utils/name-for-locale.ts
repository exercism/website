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

    // Intl gives many names in lowercase ("magyar", "español")
    return name.charAt(0).toLocaleUpperCase(displayLocale) + name.slice(1)
  } catch {
    return locale
  }
}
