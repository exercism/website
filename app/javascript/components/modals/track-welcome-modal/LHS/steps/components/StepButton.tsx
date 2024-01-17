import { assembleClassNames } from '@/utils/assemble-classnames'
import React, { ButtonHTMLAttributes } from 'react'

interface StepButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  children: React.ReactNode
}
export function StepButton({
  children,
  className,
  ...props
}: StepButtonProps): JSX.Element {
  return (
    <button
      {...props}
      className={assembleClassNames('btn-primary btn-m', className)}
    >
      {children}
    </button>
  )
}
