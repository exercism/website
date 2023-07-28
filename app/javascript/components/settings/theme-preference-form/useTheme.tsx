import { useCallback, useEffect, useState } from 'react'
import { QueryStatus } from 'react-query'
import { useDebounce } from '@/hooks'
import { useSettingsMutation } from '../useSettingsMutation'
import { setThemeClassName } from './utils'
import { Theme, ThemePreferenceLinks } from '../ThemePreferenceForm'

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
  status: QueryStatus
  error: unknown
  theme: string
}
export function useTheme(
  defaultThemePreference: string,
  links: Pick<ThemePreferenceLinks, 'update'>
): useThemeReturns {
  const [theme, setTheme] = useState<string>(defaultThemePreference || '')
  const [hasBeenUpdated, setHasBeenUpdated] = useState(false)
  const debouncedTheme = useDebounce(theme, 1000)

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
    setThemeClassName(t.value)
  }, [])

  return { handleThemeUpdate, status, error, theme }
}
