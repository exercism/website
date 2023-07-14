import { debounce } from '@/utils/debounce'
import { useState, useEffect } from 'react'

const THEMES = [
  'theme-dark',
  'theme-light',
  'theme-system',
  'theme-sepia',
  'theme-accessibility-dark',
] as const
interface ThemeData {
  theme: typeof THEMES[number]
  explicitTheme:
    | 'theme-dark'
    | 'theme-light'
    | 'theme-sepia'
    | 'theme-accessibility-dark'
}

const getExplicitTheme = (
  theme: ThemeData['theme'],
  isDarkMode: boolean
): ThemeData['explicitTheme'] => {
  if (theme === 'theme-system') {
    return isDarkMode ? 'theme-dark' : 'theme-light'
  }
  return theme
}

const getThemeFromClassList = () => {
  return THEMES.find((theme) =>
    document.body.classList.contains(theme)
  ) as ThemeData['theme']
}

function replaceThemeWith(theme: ThemeData['theme']): void {
  const classNames = Array.from(document.body.classList)

  classNames.forEach((className: string) => {
    if (className.startsWith('theme-')) {
      document.body.classList.replace(className, theme)
    }
  })
}

function patchTheme(theme: string, updateEndpoint?: string) {
  if (!updateEndpoint) return
  return fetch(updateEndpoint, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      user_preferences: { theme },
    }),
  })
    .then((res) => res.json())
    .catch((e) =>
      // eslint-disable-next-line no-console
      console.error('Failed to update to accessibility-dark theme: ', e)
    )
}

const patchThemeDebounced = debounce(patchTheme, 1000)

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

    const mediaQueryListDark = window.matchMedia('(prefers-color-scheme: dark)')
    const mediaQueryListenerDark = () => {
      const isDark = mediaQueryListDark.matches
      setIsDarkMode(isDark)
      if (themeData.theme === 'theme-system') {
        setThemeData((prev) => ({
          ...prev,
          explicitTheme: getExplicitTheme(prev.theme, isDark),
        }))
      }
    }
    const mediaQueryListAccessibilityDark = window.matchMedia(
      '(prefers-contrast: more)'
    )
    const mediaQueryListenerAccessibilityDark = () => {
      if (mediaQueryListAccessibilityDark.matches) {
        replaceThemeWith('theme-accessibility-dark')
        patchThemeDebounced('accessibility-dark', updateEndpoint)
      } else {
        replaceThemeWith('theme-light')
        patchThemeDebounced('light', updateEndpoint)
      }
    }

    mediaQueryListDark.addEventListener('change', mediaQueryListenerDark)
    mediaQueryListAccessibilityDark.addEventListener(
      'change',
      mediaQueryListenerAccessibilityDark
    )

    return () => {
      observer.disconnect()
      mediaQueryListDark.removeEventListener('change', mediaQueryListenerDark)
      mediaQueryListAccessibilityDark.removeEventListener(
        'change',
        mediaQueryListenerAccessibilityDark
      )
    }
  }, [themeData.theme, isDarkMode, updateEndpoint])

  return themeData
}
