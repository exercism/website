import React from 'react'
import { Tab } from './Tab'
import { TabIndex } from '../Editor'

export const TestsPanel = () => (
  <Tab.Panel index={TabIndex.TESTS}>
    <section className="tests"></section>
  </Tab.Panel>
)
