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
      <h1>It&apos;s time to rate your mentor</h1>
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
