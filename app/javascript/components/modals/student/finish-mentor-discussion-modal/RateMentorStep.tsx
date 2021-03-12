import React from 'react'

export const RateMentorStep = ({
  onHappy,
}: {
  onHappy: () => void
}): JSX.Element => {
  return (
    <div>
      <button type="button" onClick={onHappy}>
        Happy
      </button>
    </div>
  )
}
