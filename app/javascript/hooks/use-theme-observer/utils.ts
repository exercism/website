const THEMES = [
  'theme-dark',
  'theme-light',
  'theme-system',
  'theme-sepia',
  'theme-accessibility-dark',
] as const
export interface ThemeData {
  theme: typeof THEMES[number]
  explicitTheme:
    | 'theme-dark'
    | 'theme-light'
    | 'theme-sepia'
    | 'theme-accessibility-dark'
}

export function getExplicitTheme(
  theme: ThemeData['theme'],
  isDarkMode: boolean
): ThemeData['explicitTheme'] {
  if (theme === 'theme-system') {
    return isDarkMode ? 'theme-dark' : 'theme-light'
  }
  return theme
}

export function getThemeFromClassList(): ThemeData['theme'] {
  return THEMES.find((theme) =>
    document.body.classList.contains(theme)
  ) as ThemeData['theme']
}

export function replaceThemeWith(theme: ThemeData['theme']): void {
  const classNames = Array.from(document.body.classList)

  classNames.forEach((className: string) => {
    if (className.startsWith('theme-')) {
      document.body.classList.replace(className, theme)
    }
  })
}
