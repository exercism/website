import { useDropdown } from '../useDropdown'
import { APIResponse } from '../Notifications'

export const useNotificationDropdown = (data: APIResponse | undefined) => {
  const dropdownLength = data
    ? data.results.length + (data.unrevealedBadges ? 1 : 0) + 1
    : 0

  return useDropdown(dropdownLength, undefined, {
    placement: 'bottom-start',
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
