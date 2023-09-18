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
    .then((res) => res.json())
    .catch((e) =>
      // eslint-disable-next-line no-console
      console.error('Failed to update to accessibility-dark theme: ', e)
    )
}

export const patchThemeDebounced = debounce(patchTheme, 1000)
