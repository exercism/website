import React from 'react'

export function PrimaryButton({
  onClick,
  children,
  className,
  disabled,
}: {
  onClick: () => void
  children: React.ReactChild
  className?: string
  disabled?: boolean
}): JSX.Element {
  const disabledStyle =
    'bg-disabledLight text-disabledLabel !border-transparent !shadow-none'

  return (
    <button
      onClick={onClick}
      className={`border-1 border-primaryBtnBorder shadow-xsZ1v3 bg-purple text-white text-16 font-semibold rounded-8 ${className} ${
        disabled ? disabledStyle : ''
      }`}
      disabled={disabled}
    >
      {children}
    </button>
  )
}
