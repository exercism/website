import { capitalize } from 'lodash'

export function nameForLocale(locale: string) {
  const [language] = locale.split('-')
  const languageName = new Intl.DisplayNames([locale], { type: 'language' }).of(
    language
  )

  return capitalize(languageName)
}
