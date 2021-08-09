import React from 'react'
import pluralize from 'pluralize'

export const Count = ({ number }: { number: number }): JSX.Element => {
  return (
    <h2 className="text-h4 mb-24">
      {number} {pluralize('comment', number)}
    </h2>
  )
}
