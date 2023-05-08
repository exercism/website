import { useCallback, useState } from 'react'
import { useSettingsMutation } from '../useSettingsMutation'
import { setThemeClassName } from './utils'
import { Theme, ThemePreferenceLinks } from '../ThemePreferenceForm'
import { QueryStatus } from 'react-query'

type RequestBody = {
  user_preferences: {
    theme: string
  }
}

type useThemeReturns = {
  handleThemeUpdate: (
    t: Theme,
    e: React.MouseEvent<HTMLButtonElement, MouseEvent>
  ) => void
  status: QueryStatus
  error: unknown
  theme: string
}
export function useTheme(
  defaultThemePreference: string,
  links: ThemePreferenceLinks
): useThemeReturns {
  const [theme, setTheme] = useState<string>(defaultThemePreference || '')

  const { mutation, status, error } = useSettingsMutation<RequestBody>({
    endpoint: links.update,
    method: 'PATCH',
    body: { user_preferences: { theme } },
  })

  const handleThemeUpdate = useCallback(
    (t, e) => {
      e.preventDefault()
      mutation()

      setTheme(t.value)
      setThemeClassName(t.value)
    },
    [mutation]
  )

  return { handleThemeUpdate, status, error, theme }
}
