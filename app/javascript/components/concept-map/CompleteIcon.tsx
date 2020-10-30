import React from 'react'

export const CompleteIcon = ({
  show,
}: {
  show: boolean
}): JSX.Element | null => {
  if (!show) return null

  const rootStyle = getComputedStyle(document.documentElement)
  const fillColor = rootStyle.getPropertyValue('--c-concept-map-check-green')
  const checkColor = '#26282D'

  return (
    <svg
      viewBox="0 0 16 16"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className="complete-icon"
    >
      <circle cx="8" cy="8" r="8" fill={fillColor} />
      <path
        d="M11.1545 5.13611L7.31292 10.6239C7.21009 10.7716 7.04251 10.8609 6.86253 10.8639C6.68254 10.8669 6.5121 10.7831 6.40445 10.6389L5.42725 9.33611"
        stroke={checkColor}
        strokeWidth="1.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  )
}
