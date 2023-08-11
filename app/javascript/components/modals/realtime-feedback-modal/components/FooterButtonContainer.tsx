import React from 'react'

export function FooterButtonContainer({
  children,
  className = '',
}: {
  children: React.ReactNode
  className?: string
}): JSX.Element {
  return (
    <div
      className={`flex gap-16 mt-0 -mx-48 -mb-32 py-16 px-48 border-t-1 border-borderColor6 ${className}`}
    >
      {children}
    </div>
  )
}
