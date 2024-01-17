import React, { useContext } from 'react'
import { TrackContext } from '../../..'
export function Choices({}: {}): JSX.Element {
  const { choices } = useContext(TrackContext)

  return (
    <div className="flex gap-8 mb-8">
      {Object.entries(choices).map(([key, value], id) => (
        <span
          className="py-6 px-12 bg-textColor6NoDark text-aliceBlue rounded-24"
          key={id}
        >
          {key}: {value}
        </span>
      ))}
    </div>
  )
}
