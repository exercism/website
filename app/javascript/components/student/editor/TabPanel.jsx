import React from 'react'

export function TabPanel({
  currentIndex,
  index,
  children,
}: {
  index: TabIndex,
  currentIndex: TabIndex,
  children: React.ReactNode,
}) {
  if (currentIndex !== index) {
    return null
  }

  return <div>{children}</div>
}
