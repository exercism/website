function flagForCountryCode(countryCode: string): string {
  return countryCode
    .toUpperCase()
    .split('')
    .map((char) => String.fromCodePoint(127397 + char.charCodeAt(0)))
    .join('')
}

export function flagForLocale(locale: string): string {
  let country = locale.split('-').pop()?.toLowerCase() ?? locale.toLowerCase()

  if (country === 'en') {
    country = 'us'
  }

  return flagForCountryCode(country)
}
