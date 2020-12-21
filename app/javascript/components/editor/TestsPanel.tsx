import React from 'react'
import { Tab } from '../common/Tab'
import { TabsContext } from '../Editor'

export const TestsPanel = () => (
  <Tab.Panel index="tests" context={TabsContext}>
    <section className="tests"></section>
  </Tab.Panel>
)
