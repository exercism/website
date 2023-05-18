import { useState, useEffect } from 'react'

interface ThemeData {
  theme: 'theme-dark' | 'theme-light' | 'theme-system'
  binaryTheme: 'theme-dark' | 'theme-light'
}

const getCurrentTheme = (): ThemeData => {
  const classList = document.body.className.split(' ')
  const theme = classList.find((className) =>
    ['theme-dark', 'theme-light', 'theme-system'].includes(className)
  ) as ThemeData['theme']
  let binaryTheme: ThemeData['binaryTheme']
  if (theme === 'theme-system') {
    binaryTheme = window.matchMedia('(prefers-color-scheme: dark)').matches
      ? 'theme-dark'
      : 'theme-light'
  } else {
    binaryTheme = theme
  }
  return { theme, binaryTheme }
}

export function useThemeObserver(): ThemeData {
  const [themeData, setThemeData] = useState<ThemeData>(getCurrentTheme())

  const updateBinaryTheme = (theme: ThemeData['theme']) => {
    let binaryTheme: ThemeData['binaryTheme']
    if (theme === 'theme-system') {
      binaryTheme = window.matchMedia('(prefers-color-scheme: dark)').matches
        ? 'theme-dark'
        : 'theme-light'
    } else {
      binaryTheme = theme
    }
    setThemeData((prevThemeData) => ({ ...prevThemeData, binaryTheme }))
  }

  useEffect(() => {
    const observer = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        if (mutation.attributeName === 'class') {
          const classList = document.body.className.split(' ')
          const themeClass = classList.find((className) =>
            ['theme-dark', 'theme-light', 'theme-system'].includes(className)
          ) as ThemeData['theme']
          setThemeData((prevThemeData) => ({
            ...prevThemeData,
            theme: themeClass,
          }))
          updateBinaryTheme(themeClass)
        }
      })
    })

    observer.observe(document.body, { attributes: true })

    const mediaQueryList = window.matchMedia('(prefers-color-scheme: dark)')
    const mediaQueryListener = () => {
      if (themeData.theme === 'theme-system') {
        updateBinaryTheme(themeData.theme)
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
