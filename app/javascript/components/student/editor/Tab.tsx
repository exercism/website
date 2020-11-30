import React from 'react'
import { TabIndex } from '../Editor'

export function Tab({
  index,
  currentIndex,
  setTab,
  children,
}: {
  currentIndex: TabIndex
  index: TabIndex
  setTab: (index: TabIndex) => void
  children?: React.ReactNode
}) {
  const classNames = ['c-tab']
  if (index === currentIndex) {
    classNames.push('selected')
  }

  return (
    <button
      className={classNames.join(' ')}
      type="button"
      onClick={() => {
        setTab(index)
      }}
    >
      {children}
    </button>
  )
}
