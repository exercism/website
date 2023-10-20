import { useEffect } from 'react'
import { TabIndex } from '../../Session'

export function usePanelFallback({
  tab,
  setTab,
  isBelowLgWidth,
}: {
  tab: TabIndex
  setTab: React.Dispatch<React.SetStateAction<TabIndex>>
  isBelowLgWidth: boolean
}) {
  useEffect(() => {
    if (!isBelowLgWidth && tab === 'code') {
      setTab('discussion')
    }
  }, [isBelowLgWidth])
}
