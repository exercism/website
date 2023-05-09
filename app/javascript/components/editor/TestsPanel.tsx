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
    <Tab.Panel id="tests" context={context}>
      {children}
    </Tab.Panel>
  )
}
