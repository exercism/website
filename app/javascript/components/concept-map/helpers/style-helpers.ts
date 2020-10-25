const computedRootStyle = getComputedStyle(document.documentElement)

export const getLineWidth = () => {
  return Number(
    computedRootStyle.getPropertyValue('--c-concept-map-line-width')
  )
}

export const getCircleRadius = () => {
  return Number(
    computedRootStyle.getPropertyValue('--c-concept-map-circle-radius')
  )
}
