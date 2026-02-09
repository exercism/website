import { debounce } from '@/utils'

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
    .then((res) => {
      if (!res.ok) throw new Error('Failed to update theme')
      return res.json()
    })
    .catch((e) =>
      // eslint-disable-next-line no-console
      console.error('Failed to update to accessibility-dark theme: ', e)
    )
}

export const patchThemeDebounced = debounce(patchTheme, 1000)
