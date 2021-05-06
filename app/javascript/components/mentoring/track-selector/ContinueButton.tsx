import React from 'react'

export const ContinueButton = (
  props: React.ButtonHTMLAttributes<HTMLButtonElement>
): JSX.Element => {
  return (
    <button className="btn-primary btn-m" {...props}>
      <span>Continue</span>
    </button>
  )
}
