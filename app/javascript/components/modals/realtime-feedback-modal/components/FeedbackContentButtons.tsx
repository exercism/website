import { assembleClassNames } from '@/utils/assemble-classnames'
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
  text = 'Continue',
  className,
  ...props
}: {
  text?: string
  className?: string
} & ReactButton): JSX.Element {
  return (
    <button
      {...props}
      className={assembleClassNames('btn-primary btn-s', className)}
    >
      {text}
    </button>
  )
}
