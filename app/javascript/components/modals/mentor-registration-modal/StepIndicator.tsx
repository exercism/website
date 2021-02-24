import React from 'react'

export const StepIndicator = (): JSX.Element => {
  return (
    <div className="steps">
      <div className="step selected" />
      <div className="step" />
      <div className="step" />
    </div>
  )
}
