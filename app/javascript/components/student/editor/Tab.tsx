import React, { useContext } from 'react'
import { TabsContext, TabIndex } from '../Editor'

export function Tab({
  index,
  children,
}: {
  index: TabIndex
  children?: React.ReactNode
}) {
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
