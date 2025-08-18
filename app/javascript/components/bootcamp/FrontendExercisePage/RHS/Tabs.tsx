import React from 'react'
import { Tab } from '@/components/common'
import { TabsContext } from './RHS'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function Tabs() {
  return (
    <div className="tabs">
      <InstructionsTab />
      <OutputTab />
      <ExpectedTab />
      <ConsoleTab />
    </div>
  )
}

function InstructionsTab() {
  const { t } = useAppTranslation(
    'components/bootcamp/FrontendExercisePage/RHS'
  )
  return (
    <Tab id="instructions" context={TabsContext}>
      <span data-text="Instructions">{t('tabs.instructions')}</span>
    </Tab>
  )
}

function OutputTab() {
  const { t } = useAppTranslation(
    'components/bootcamp/FrontendExercisePage/RHS'
  )
  return (
    <Tab id="output" context={TabsContext}>
      <span data-text="Output">{t('tabs.output')}</span>
    </Tab>
  )
}

function ExpectedTab() {
  const { t } = useAppTranslation(
    'components/bootcamp/FrontendExercisePage/RHS'
  )
  return (
    <Tab id="expected" context={TabsContext}>
      <span data-text="Expected">{t('tabs.expected')}</span>
    </Tab>
  )
}

function ConsoleTab() {
  const { t } = useAppTranslation(
    'components/bootcamp/FrontendExercisePage/RHS'
  )
  return (
    <Tab id="console" context={TabsContext}>
      <span data-text="Console">{t('tabs.console')}</span>
    </Tab>
  )
}
