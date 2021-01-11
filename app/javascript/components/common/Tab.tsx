import React, { useContext } from 'react'

export type TabContext = {
  current: string
  switchToTab: (index: string) => void
}

export const Tab = ({
  context,
  id,
  children,
}: {
  context: React.Context<TabContext>
  id: string
  children?: React.ReactNode
}): JSX.Element => {
  const { current, switchToTab } = useContext(context)

  const classNames = ['c-tab']
  if (id === current) {
    classNames.push('selected')
  }

  return (
    <button
      className={classNames.join(' ')}
      role="tab"
      aria-selected={id === current}
      aria-controls={`panel-${id}`}
      id={`tab-${id}`}
      tabIndex={id === current ? 0 : -1}
      onClick={() => {
        switchToTab(id)
      }}
    >
      {children}
    </button>
  )
}

const TabPanel = ({
  id,
  children,
  context,
}: {
  id: string
  children: React.ReactNode
  context: React.Context<TabContext>
}) => {
  const { current } = useContext(context)

  return (
    <div
      id={`panel-${id}`}
      role="tabpanel"
      aria-labelledby={`tab-${id}`}
      tabIndex={0}
      hidden={id !== current}
      className="--tab-panel"
    >
      {children}
    </div>
  )
}
TabPanel.displayName = 'TabPanel'
Tab.Panel = TabPanel

const TabTitle = ({ text }: { text: string }) => {
  return <span data-text={text}>{text}</span>
}
TabTitle.displayName = 'TabTitle'
Tab.Title = TabTitle
