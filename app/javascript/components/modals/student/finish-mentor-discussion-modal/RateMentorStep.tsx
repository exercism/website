import React from 'react'

export const RateMentorStep = ({
  onHappy,
  onSatisfied,
}: {
  onHappy: () => void
  onSatisfied: () => void
}): JSX.Element => {
  return (
    <div>
      <button type="button" onClick={onHappy}>
        Happy
      </button>
      <button type="button" onClick={onSatisfied}>
        Satisfied
      </button>
    </div>
  )
}
