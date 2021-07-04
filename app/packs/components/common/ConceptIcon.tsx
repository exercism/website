import React from 'react'

export const ConceptIcon = ({
  name,
  size,
}: {
  name: string
  size: 'small' | 'medium' | 'large'
}): JSX.Element => {
  return (
    <div className={`c-concept-icon c--${size}`}>{name.substring(0, 2)}</div>
  )
}
