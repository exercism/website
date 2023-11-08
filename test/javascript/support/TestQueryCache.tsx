import React from 'react'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'

export const TestQueryCache = ({
  children,
  queryClient,
}: {
  children?: React.ReactElement
  queryClient: any
}): JSX.Element => {
  const localQueryClient = new QueryClient({
    defaultOptions: {
      queries: { retry: false },
    },
  })
  return (
    <QueryClientProvider client={queryClient || localQueryClient}>
      {children}
    </QueryClientProvider>
  )
}
