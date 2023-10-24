import React, { forwardRef, useContext } from 'react'
import { ScreenSizeContext } from '../mentoring/session/ScreenSizeContext'
import { assembleClassNames } from '@/utils/assemble-classnames'

export type TabContext = {
  current: string
  switchToTab: (index: string) => void
}

export const Tab = ({
  context,
  id,
  children,
  className,
}: {
  context: React.Context<TabContext>
  id: string
  children?: React.ReactNode
  className?: string
}): JSX.Element => {
  const { current, switchToTab } = useContext(context)

  const classNames = ['c-tab', className]
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

type PanelProps = {
  id: string
  className?: string
  children: React.ReactNode
  context: React.Context<TabContext>
}

const TabPanel = forwardRef<HTMLDivElement, PanelProps>(
  ({ id, className, children, context }, ref): JSX.Element | null => {
    const { current } = useContext(context)
    const { isBelowLgWidth = false } = useContext(ScreenSizeContext) || {}

    const style = id !== current ? { display: 'none' } : undefined

    return (
      <div
        id={`panel-${id}`}
        role="tabpanel"
        aria-labelledby={`tab-${id}`}
        tabIndex={0}
        className={assembleClassNames(
          '--tab-panel',
          isBelowLgWidth ? 'mobile' : '',
          className
        )}
        ref={ref}
        style={style}
      >
        {children}
      </div>
    )
  }
)

TabPanel.displayName = 'TabPanel'
Tab.Panel = TabPanel

const TabTitle = ({ text }: { text: string }) => {
  return <span data-text={text}>{text}</span>
}
TabTitle.displayName = 'TabTitle'
Tab.Title = TabTitle
