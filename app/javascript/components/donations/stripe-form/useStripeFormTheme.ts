import { useState, useEffect } from 'react'
import { useThemeObserver } from '@/hooks/use-theme-observer'
import { bodyHasClassName } from '@/utils'

export function useStripeFormTheme(): 'light' | 'dark' {
  const [theme, setTheme] = useState<'light' | 'dark'>('light')
  const { explicitTheme } = useThemeObserver()

  const alwaysDark = bodyHasClassName('controller-insiders')

  useEffect(() => {
    if (
      (explicitTheme === 'theme-light' || explicitTheme === 'theme-sepia') &&
      !alwaysDark
    ) {
      setTheme('light')
    } else setTheme('dark')
  }, [alwaysDark, explicitTheme])

  return theme
}
