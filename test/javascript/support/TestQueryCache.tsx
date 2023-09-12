import React from 'react'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'

export const TestQueryCache = ({
  children,
  queryClient,
}: {
  children?: React.ReactElement
  queryClient: any
}): JSX.Element => {
  return (
    <QueryClientProvider client={queryClient || new QueryClient()}>
      {children}
    </QueryClientProvider>
  )
}
