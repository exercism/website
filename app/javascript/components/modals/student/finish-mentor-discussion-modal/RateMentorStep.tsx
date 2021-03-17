import React from 'react'

export const RateMentorStep = ({
  onHappy,
  onSatisfied,
  onUnhappy,
}: {
  onHappy: () => void
  onSatisfied: () => void
  onUnhappy: () => void
}): JSX.Element => {
  return (
    <div>
      <button type="button" onClick={onHappy}>
        Happy
      </button>
      <button type="button" onClick={onSatisfied}>
        Satisfied
      </button>
      <button type="button" onClick={onUnhappy}>
        Unhappy
      </button>
    </div>
  )
}
