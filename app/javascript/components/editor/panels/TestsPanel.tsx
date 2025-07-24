import React from 'react'
import { Tab, TabContext } from '@/components/common/Tab'

export function TestsPanel({
  context,
  children,
}: {
  context: React.Context<TabContext>
  children: React.ReactNode
}): JSX.Element {
  return (
    <Tab.Panel id="tests" className="overflow-auto" context={context}>
      {children}
    </Tab.Panel>
  )
}
