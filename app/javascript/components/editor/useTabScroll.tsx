import { useCallback, useState } from 'react'
import { TabIndex } from '../Editor'

type ScrollPosition = {
  [tab in TabIndex]: number
}

export const useTabScroll = (
  tab: TabIndex,
  container: HTMLDivElement | null
): {
  handleScroll: (event: React.UIEvent<HTMLDivElement, UIEvent>) => void
  scrollTo: (tab: TabIndex) => void
} => {
  const [scrollPosition, setScrollPosition] = useState<ScrollPosition>({
    instructions: 0,
    tests: 0,
    results: 0,
  })

  const handleScroll = useCallback(
    (e) => {
      setScrollPosition({
        ...scrollPosition,
        [tab]: (e.target as HTMLElement).scrollTop,
      })
    },
    [scrollPosition, tab]
  )

  const scrollTo = useCallback(
    (tab: TabIndex) => {
      if (!container) {
        return
      }

      container.scrollTo({ top: scrollPosition[tab] })
    },
    [container, scrollPosition]
  )

  return { handleScroll, scrollTo }
}
