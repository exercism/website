let requestedAnimationFrame: number | null = null

export const wrapAnimationFrame = (
  fn: (...args: any[]) => any
): ((...args: any[]) => void) => {
  return (...args) => {
    if (requestedAnimationFrame) {
      window.cancelAnimationFrame(requestedAnimationFrame)
    }
    requestedAnimationFrame = window.requestAnimationFrame(() => {
      fn.apply(null, args)
    })
  }
}
