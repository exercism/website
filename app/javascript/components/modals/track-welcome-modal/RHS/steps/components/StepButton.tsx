import React, { ButtonHTMLAttributes } from 'react'

interface StepButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  children: React.ReactNode
}
export function StepButton({
  children,
  ...props
}: StepButtonProps): JSX.Element {
  return (
    <button {...props} className="btn-primary btn-m">
      {children}
    </button>
  )
}
