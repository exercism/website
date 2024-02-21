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
    const mediaQueryListenerPrefersContrastMore = () => {
      if (mediaQueryPrefersContrastMore.matches) {
        replaceThemeWith('theme-accessibility-dark')
        patchThemeDebounced('accessibility-dark', updateEndpoint)
      } else if (getThemeFromClassList() === 'theme-accessibility-dark') {
        replaceThemeWith('theme-light')
        patchThemeDebounced('light', updateEndpoint)
      }
    }

    addMediaQueryListener(
      mediaQueryPrefersColorSchemeDark,
      mediaQueryListenerPrefersColorSchemeDark
    )
    addMediaQueryListener(
      mediaQueryPrefersContrastMore,
      mediaQueryListenerPrefersContrastMore
    )

    return () => {
      observer.disconnect()
      removeMediaQueryListener(
        mediaQueryPrefersColorSchemeDark,
        mediaQueryListenerPrefersColorSchemeDark
      )
      removeMediaQueryListener(
        mediaQueryPrefersContrastMore,
        mediaQueryListenerPrefersContrastMore
      )
    }
  }, [themeData.theme, isDarkMode, updateEndpoint])

  return themeData
}

function addMediaQueryListener(
  mediaQueryList: MediaQueryList,
  listener: (ev: MediaQueryListEvent) => void
) {
  if (mediaQueryList.addEventListener) {
    mediaQueryList.addEventListener('change', listener)
  } else {
    // Fallback for Safari < 14 and other older browsers
    mediaQueryList.addListener(listener)
  }
}

function removeMediaQueryListener(
  mediaQueryList: MediaQueryList,
  listener: (ev: MediaQueryListEvent) => void
) {
  if (mediaQueryList.removeEventListener) {
    mediaQueryList.removeEventListener('change', listener)
  } else {
    // Fallback for Safari < 14 and other older browsers
    mediaQueryList.removeListener(listener)
  }
}
