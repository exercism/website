export type Visibility = 'visible' | 'hidden'
type VisibilityListener = (next: Visibility) => void

let conceptVisibility: Visibility = 'hidden'
const visibilityListeners: VisibilityListener[] = []

export const addVisibilityListener = (listener: VisibilityListener): void => {
  visibilityListeners.push(listener)
  if (conceptVisibility === 'visible') {
    listener('visible')
  }
}

export const removeVisibilityListener = (
  listener: VisibilityListener
): void => {
  const listenerIndex = visibilityListeners.indexOf(listener)
  if (listenerIndex > -1) {
    visibilityListeners.splice(listenerIndex, 1)
  }
}

export const triggerVisibility = (): void => {
  if (conceptVisibility === 'hidden') {
    conceptVisibility = 'visible'
  }
  visibilityListeners.forEach((listeners) => listeners('visible'))
}
