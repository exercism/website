import React from 'react'
import { makeQueryCache, ReactQueryCacheProvider } from 'react-query'

export const TestQueryCache = ({
  children,
}: {
  children: React.ReactNode
}): JSX.Element => {
  const queryCache = makeQueryCache({
    defaultConfig: {
      queries: {
        retry: false,
      },
    },
  })

  return (
    <ReactQueryCacheProvider queryCache={queryCache}>
      {children}
    </ReactQueryCacheProvider>
  )
}
