import React from 'react'

export const PathLineEndSVG = ({
  cx,
  cy,
  radius,
}: {
  cx: number
  cy: number
  radius: number
}): JSX.Element => {
  return <circle cx={cx} cy={cy} r={radius} />
}

export const PurePathLineEndSVG = React.memo(PathLineEndSVG)
