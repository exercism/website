import React from 'react'

export function ButtonContainer({
  children,
}: {
  children: React.ReactNode
}): JSX.Element {
  return <div className="flex gap-12 items-center mt-16">{children}</div>
}
