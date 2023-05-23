import { useState, useEffect } from 'react'

interface ThemeData {
  theme: 'theme-dark' | 'theme-light' | 'theme-system'
  binaryTheme: 'theme-dark' | 'theme-light'
}

const THEMES = ['theme-dark', 'theme-light', 'theme-system']

const getBinaryTheme = (
  theme: ThemeData['theme'],
  isDarkMode: boolean
): ThemeData['binaryTheme'] => {
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

export function useThemeObserver(): ThemeData {
  const [isDarkMode, setIsDarkMode] = useState(
    window.matchMedia('(prefers-color-scheme: dark)').matches
  )
  const [themeData, setThemeData] = useState<ThemeData>({
    theme: getThemeFromClassList(),
    binaryTheme: getBinaryTheme(getThemeFromClassList(), isDarkMode),
  })

  useEffect(() => {
    const observer = new MutationObserver((mutations) => {
      for (const mutation of mutations) {
        if (mutation.attributeName === 'class') {
          const theme = getThemeFromClassList()
          setThemeData({
            theme,
            binaryTheme: getBinaryTheme(theme, isDarkMode),
          })
          break
        }
      }
    })

    observer.observe(document.body, { attributes: true })

    const mediaQueryList = window.matchMedia('(prefers-color-scheme: dark)')
    const mediaQueryListener = () => {
      const isDark = mediaQueryList.matches
      setIsDarkMode(isDark)
      if (themeData.theme === 'theme-system') {
        setThemeData((prev) => ({
          ...prev,
          binaryTheme: getBinaryTheme(prev.theme, isDark),
        }))
      }
    }
    mediaQueryList.addEventListener('change', mediaQueryListener)

    return () => {
      observer.disconnect()
      mediaQueryList.removeEventListener('change', mediaQueryListener)
    }
  }, [themeData.theme, isDarkMode])

  return themeData
}
