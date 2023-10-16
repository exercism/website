import React from 'react'

export function AlertTag({
  children,
}: {
  children: React.ReactNode
}): JSX.Element {
  return (
    <div className="flex items-center text-alert bg-veryLightRed text-13 rounded-8 font-semibold py-6 px-12 animate-fadeIn">
      {children}
    </div>
  )
}
