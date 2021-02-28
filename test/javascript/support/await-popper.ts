import { waitFor } from '@testing-library/react'

// There is an issue where createPopper() runs its first update() asynchronously,
// which leads to the Render not actually being completed.
//
// Calling:
// await awaitPopper()
// should fix it
//
// Read more here: https://github.com/popperjs/react-popper/issues/350
export function awaitPopper() {
  return waitFor(() => {})
}
