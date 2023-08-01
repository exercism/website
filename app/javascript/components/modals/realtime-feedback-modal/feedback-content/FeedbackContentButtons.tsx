import React from 'react'

type ReactButton = React.ButtonHTMLAttributes<HTMLButtonElement>

export function GoBackToExercise({ ...props }: ReactButton): JSX.Element {
  return (
    <button {...props} className="btn-s btn-primary">
      Go back to editor
    </button>
  )
}

export function ContinueButton({
  anyway,
  ...props
}: {
  anyway?: boolean
} & ReactButton): JSX.Element {
  return (
    <button {...props} className="btn-primary btn-s">
      Continue{anyway ? ' anyway' : null}
    </button>
  )
}
