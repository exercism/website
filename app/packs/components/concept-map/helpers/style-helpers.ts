const computedRootStyle = getComputedStyle(document.documentElement)

export const getLineWidth = (): number => {
  return Number(
    computedRootStyle.getPropertyValue('--c-concept-map-line-width')
  )
}

export const getCircleRadius = (): number => {
  return Number(
    computedRootStyle.getPropertyValue('--c-concept-map-circle-radius')
  )
}

export const getDrawingMargin = (): number => {
  return Number(
    computedRootStyle.getPropertyValue('--c-concept-map-drawing-margin')
  )
}
