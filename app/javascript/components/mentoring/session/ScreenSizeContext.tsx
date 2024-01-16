import { UseWindowSizeResult, useWindowSize } from '@/hooks/use-screen-size'
import React, { createContext } from 'react'

export const ScreenSizeContext = createContext<null | UseWindowSizeResult>(null)

export function ScreenSizeWrapper({ children }: { children: React.ReactNode }) {
  const windowSizeData = useWindowSize()
  return (
    <ScreenSizeContext.Provider value={windowSizeData}>
      {children}
    </ScreenSizeContext.Provider>
  )
}
