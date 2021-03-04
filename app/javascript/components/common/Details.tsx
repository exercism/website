import React from 'react'

export const Details = ({
  className,
  isOpen,
  label,
  children,
}: {
  className?: string
  isOpen: boolean
  label: string
  children?: React.ReactNode
}): JSX.Element => {
  return (
    <details
      aria-label={label}
      className={`c-details ${className}`}
      open={isOpen}
    >
      {children}
    </details>
  )
}

const DetailsSummary = ({
  className,
  onClick,
  children,
}: {
  className?: string
  onClick?: () => void
  children?: React.ReactNode
}): JSX.Element => {
  return (
    <summary onClick={onClick} className={className}>
      {children}
    </summary>
  )
}
DetailsSummary.displayName = 'DetailsSummary'
Details.Summary = DetailsSummary
