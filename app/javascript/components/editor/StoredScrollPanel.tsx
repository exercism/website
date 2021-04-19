import React, { useRef, useEffect } from 'react'
import { TabIndex } from '../Editor'
import { useTabScroll } from './useTabScroll'

export const StoredScrollPanel = ({
  tab,
  children,
}: React.PropsWithChildren<{ tab: TabIndex }>): JSX.Element => {
  const panelContainerRef = useRef<HTMLDivElement>(null)

  const { handleScroll, scrollTo } = useTabScroll(
    tab,
    panelContainerRef.current
  )

  useEffect(() => {
    scrollTo(tab)
  }, [scrollTo, tab])

  return (
    <div className="main-rhs" onScroll={handleScroll} ref={panelContainerRef}>
      {children}
    </div>
  )
}
