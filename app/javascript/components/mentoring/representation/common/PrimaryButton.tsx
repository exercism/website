import React from 'react'

export function PrimaryButton({
  onClick,
  children,
  className,
}: {
  onClick: () => void
  children: React.ReactChild
  className?: string
}): JSX.Element {
  return (
    // there could be an alias/class for this
    <button
      onClick={onClick}
      className={`border-1 border-primaryBtnBorder shadow-xsZ1v3 bg-purple text-white text-16 font-semibold rounded-8 ${className}`}
    >
      {children}
    </button>
  )
}
