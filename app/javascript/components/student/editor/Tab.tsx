import React, { useContext } from 'react'
import { TabsContext, TabIndex } from '../Editor'

export const Tab = ({
  index,
  children,
}: {
  index: TabIndex
  children?: React.ReactNode
}) => {
  const { tab: currentIndex, switchToTab } = useContext(TabsContext)

  const classNames = ['c-tab']
  if (index === currentIndex) {
    classNames.push('selected')
  }

  return (
    <button
      className={classNames.join(' ')}
      type="button"
      onClick={() => {
        switchToTab(index)
      }}
    >
      {children}
    </button>
  )
}

Tab.Panel = ({
  index,
  children,
}: {
  index: TabIndex
  children: React.ReactNode
}) => {
  const { tab: currentIndex, switchToTab } = useContext(TabsContext)

  if (currentIndex !== index) {
    return null
  }

  return <div>{children}</div>
}
