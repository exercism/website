import React, { useContext, useLayoutEffect, useRef, useState } from 'react'
import { TabsContext, TasksContext } from '../Editor'
import { Tab } from '@/components/common/Tab'

export function TestsPanel({
  children,
}: {
  children: React.ReactNode
}): JSX.Element {
  return (
    <Tab.Panel id="tests" context={TabsContext}>
      {children}
    </Tab.Panel>
  )
}
