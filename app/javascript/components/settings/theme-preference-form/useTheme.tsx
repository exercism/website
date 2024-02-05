import { useCallback, useEffect, useState } from 'react'
import { MutationStatus } from '@tanstack/react-query'
import { useDebounce } from '@/hooks'
import { useSettingsMutation } from '../useSettingsMutation'
import { setThemeClassName } from './utils'
import { Theme, ThemePreferenceLinks } from '../ThemePreferenceForm'
import { useLocalStorage } from '@/utils/use-storage'

type RequestBody = {
  user_preferences: {
    theme: string
  }
}

type useThemeReturns = {
  handleThemeUpdate: (
    t: Pick<Theme, 'value'>,
    e: React.MouseEvent<HTMLButtonElement, MouseEvent>
  ) => void
  status: MutationStatus
  error: unknown
  theme: string
}
export function useTheme(
  defaultThemePreference: string,
  links: Pick<ThemePreferenceLinks, 'update'>
): useThemeReturns {
  const [hasBeenUpdated, setHasBeenUpdated] = useState(false)
  const [storedTheme, setStoredTheme] = useLocalStorage<{
    theme: string
    time: number
  }>('theme-preference', {
    theme: defaultThemePreference,
    time: Date.now(),
  })
  const [theme, setTheme] = useState<string>(storedTheme.theme || '')
  const debouncedTheme = useDebounce(theme, 500)

  useEffect(() => {
    if (hasFiveMinElapsed(storedTheme.time)) {
      setStoredTheme({ theme: defaultThemePreference, time: Date.now() })
    }
  }, [])

  const { mutation, status, error } = useSettingsMutation<RequestBody>({
    endpoint: links.update,
    method: 'PATCH',
    body: { user_preferences: { theme: debouncedTheme } },
    onSuccess: () => setHasBeenUpdated(true),
  })

  useEffect(() => {
    if (
      debouncedTheme &&
      (debouncedTheme !== defaultThemePreference || hasBeenUpdated)
    ) {
      mutation()
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [debouncedTheme])

  const handleThemeUpdate = useCallback((t, e) => {
    e.preventDefault()
    setTheme(t.value)
    setStoredTheme({ theme: t.value, time: Date.now() })
    setThemeClassName(t.value)
  }, [])

  return { handleThemeUpdate, status, error, theme }
}

function hasFiveMinElapsed(startTimestampMs: number): boolean {
  const oneMinuteMs = 60000
  return Date.now() - startTimestampMs >= 5 * oneMinuteMs
}
