import React from 'react'
import { makeQueryCache, ReactQueryCacheProvider } from 'react-query'

export const TestQueryCache = ({
  children,
  enabled = true,
}: {
  children: React.ReactNode
  enabled?: boolean
}): JSX.Element => {
  const queryCache = makeQueryCache({
    defaultConfig: {
      queries: {
        retry: false,
        enabled: enabled,
      },
    },
  })

  return (
    <ReactQueryCacheProvider queryCache={queryCache}>
      {children}
    </ReactQueryCacheProvider>
  )
}
