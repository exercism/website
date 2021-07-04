import { useDropdown } from '../useDropdown'
import { APIResponse } from '../Notifications'

export const useNotificationDropdown = (data: APIResponse | undefined) => {
  const dropdownLength = data ? data.results.length + 1 : 0

  return useDropdown(dropdownLength, undefined, {
    placement: 'bottom-end',
    modifiers: [
      {
        name: 'offset',
        options: {
          offset: [0, 8],
        },
      },
    ],
  })
}
