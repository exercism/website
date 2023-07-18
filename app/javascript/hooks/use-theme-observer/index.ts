import { useState, useEffect } from 'react'
import {
  ThemeData,
  getThemeFromClassList,
  getExplicitTheme,
  replaceThemeWith,
} from './utils'
import { patchThemeDebounced } from './patch-theme'

export function useThemeObserver(updateEndpoint?: string): ThemeData {
  const [isDarkMode, setIsDarkMode] = useState(
    window.matchMedia('(prefers-color-scheme: dark)').matches
  )
  const [themeData, setThemeData] = useState<ThemeData>({
    theme: getThemeFromClassList(),
    explicitTheme: getExplicitTheme(getThemeFromClassList(), isDarkMode),
  })

  useEffect(() => {
    const observer = new MutationObserver((mutations) => {
      for (const mutation of mutations) {
        if (mutation.attributeName === 'class') {
          const theme = getThemeFromClassList()
          setThemeData({
            theme,
            explicitTheme: getExplicitTheme(theme, isDarkMode),
          })
          break
        }
      }
    })

    observer.observe(document.body, { attributes: true })

    // SYSTEM DARK THEME
    const mediaQueryPrefersColorSchemeDark = window.matchMedia(
      '(prefers-color-scheme: dark)'
    )
    const mediaQueryListenerPrefersColorSchemeDark = () => {
      const isDark = mediaQueryPrefersColorSchemeDark.matches
      setIsDarkMode(isDark)
      if (themeData.theme === 'theme-system') {
        setThemeData((prev) => ({
          ...prev,
          explicitTheme: getExplicitTheme(prev.theme, isDark),
        }))
      }
    }

    // ACCESSIBILITY DARK THEME
    const mediaQueryPrefersContrastMore = window.matchMedia(
      '(prefers-contrast: more)'
    )
    if (mediaQueryPrefersContrastMore.matches) {
      replaceThemeWith('theme-accessibility-dark')
      patchThemeDebounced('accessibility-dark', updateEndpoint)
    }
    const mediaQueryListenerPrefersContrastMore = () => {
      if (mediaQueryPrefersContrastMore.matches) {
        replaceThemeWith('theme-accessibility-dark')
        patchThemeDebounced('accessibility-dark', updateEndpoint)
      } else {
        replaceThemeWith('theme-light')
        patchThemeDebounced('light', updateEndpoint)
      }
    }

    mediaQueryPrefersColorSchemeDark.addEventListener(
      'change',
      mediaQueryListenerPrefersColorSchemeDark
    )
    mediaQueryPrefersContrastMore.addEventListener(
      'change',
      mediaQueryListenerPrefersContrastMore
    )

    return () => {
      observer.disconnect()
      mediaQueryPrefersColorSchemeDark.removeEventListener(
        'change',
        mediaQueryListenerPrefersColorSchemeDark
      )
      mediaQueryPrefersContrastMore.removeEventListener(
        'change',
        mediaQueryListenerPrefersContrastMore
      )
    }
  }, [themeData.theme, isDarkMode, updateEndpoint])

  return themeData
}
