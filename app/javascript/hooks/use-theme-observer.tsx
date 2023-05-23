import { useState, useEffect } from 'react'

interface ThemeData {
  theme: 'theme-dark' | 'theme-light' | 'theme-system'
  binaryTheme: 'theme-dark' | 'theme-light'
}

const THEMES = ['theme-dark', 'theme-light', 'theme-system']

const getBinaryTheme = (
  theme: ThemeData['theme']
): ThemeData['binaryTheme'] => {
  if (theme === 'theme-system') {
    return window.matchMedia('(prefers-color-scheme: dark)').matches
      ? 'theme-dark'
      : 'theme-light'
  }
  return theme
}

const getCurrentTheme = (): ThemeData => {
  const theme = THEMES.find((theme) =>
    document.body.classList.contains(theme)
  ) as ThemeData['theme']
  const binaryTheme = getBinaryTheme(theme)
  return { theme, binaryTheme }
}

export function useThemeObserver(): ThemeData {
  const [themeData, setThemeData] = useState<ThemeData>(getCurrentTheme())

  useEffect(() => {
    const observer = new MutationObserver((mutations) => {
      for (const mutation of mutations) {
        if (mutation.attributeName === 'class') {
          const theme = THEMES.find((theme) =>
            document.body.classList.contains(theme)
          ) as ThemeData['theme']
          const binaryTheme = getBinaryTheme(theme)
          setThemeData({ theme, binaryTheme })
          break
        }
      }
    })

    observer.observe(document.body, { attributes: true })

    const mediaQueryList = window.matchMedia('(prefers-color-scheme: dark)')
    const mediaQueryListener = () => {
      if (themeData.theme === 'theme-system') {
        const binaryTheme = getBinaryTheme(themeData.theme)
        setThemeData((prevThemeData) => ({ ...prevThemeData, binaryTheme }))
      }
    }
    mediaQueryList.addEventListener('change', mediaQueryListener)

    return () => {
      observer.disconnect()
      mediaQueryList.removeEventListener('change', mediaQueryListener)
    }
  }, [themeData.theme])

  return themeData
}
