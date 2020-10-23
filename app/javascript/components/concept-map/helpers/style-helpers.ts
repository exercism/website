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

export const getLineColor = (
  type: 'locked' | 'complete' | 'available' = 'locked'
) => computedRootStyle.getPropertyValue(`--c-concept-map-line-${type}`)

export const getLineDasharray = (type: 'solid' | 'dashed' = 'solid') =>
  computedRootStyle.getPropertyValue(`--c-concept-map-line-dasharray-${type}`)

export const getTextColor = (type: 'unlocked' | 'locked' = 'locked') =>
  computedRootStyle.getPropertyValue(`--c-concept-map-line-${type}`)

export const getConceptMapStylePropertyValue = (
  type:
    | 'background'
    | 'card-background'
    | 'check-green'
    | 'line-complete'
    | 'line-available'
    | 'line-locked'
    | 'line-dasharray-dashed'
    | 'line-dasharray-solid'
    | 'text-unlocked'
    | 'text-locked'
    | 'line-width'
    | 'circle-radius'
    | 'hover-opacity'
) => computedRootStyle.getPropertyValue(`--c-concept-map-${type}`)
