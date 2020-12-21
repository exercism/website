import React, { useContext } from 'react'

export type TabContext = {
  tab: string
  switchToTab: (index: string) => void
}

export const Tab = ({
  context,
  index,
  children,
}: {
  context: React.Context<TabContext>
  index: string
  children?: React.ReactNode
}): JSX.Element => {
  const { tab: currentIndex, switchToTab } = useContext(context)

  const classNames = ['c-tab']
  if (index === currentIndex) {
    classNames.push('selected')
  }

  return (
    <button
      className={classNames.join(' ')}
      role="tab"
      aria-selected={currentIndex === index}
      aria-controls={`panel-${index}`}
      id={`tab-${index}`}
      tabIndex={currentIndex === index ? 0 : -1}
      onClick={() => {
        switchToTab(index)
      }}
    >
      {children}
    </button>
  )
}

const TabPanel = ({
  index,
  children,
  context,
}: {
  index: string
  children: React.ReactNode
  context: React.Context<TabContext>
}) => {
  const { tab: currentIndex } = useContext(context)

  return (
    <div
      id={`panel-${index}`}
      role="tabpanel"
      aria-labelledby={`tab-${index}`}
      tabIndex={0}
      hidden={index !== currentIndex}
    >
      {children}
    </div>
  )
}
TabPanel.displayName = 'TabPanel'
Tab.Panel = TabPanel
