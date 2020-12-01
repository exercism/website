import React, { useContext } from 'react'
import { TabsContext, TabIndex } from '../Editor'

export function TabPanel({
  index,
  children,
}: {
  index: TabIndex,
  children: React.ReactNode,
}) {
  const { tab: currentIndex, switchToTab } = useContext(TabsContext)

  if (currentIndex !== index) {
    return null
  }

  return <div>{children}</div>
}
