import { capitalize } from 'lodash'

export function nameForLocale(
  locale: string,
  options: { displayInEnglish?: boolean } = { displayInEnglish: false }
) {
  const [language] = locale.split('-')
  const displayLocale = options.displayInEnglish ? 'en' : locale
  const languageName = new Intl.DisplayNames([displayLocale], {
    type: 'language',
  }).of(language)

  return capitalize(languageName)
}
