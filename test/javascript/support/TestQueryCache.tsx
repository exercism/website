import React from 'react'
import { QueryClientProvider } from '@tanstack/react-query'

export const TestQueryCache = ({
  children,
  queryClient,
}: {
  children?: React.ReactElement
  queryClient: any
}): JSX.Element => {
  return (
    <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
  )
}
