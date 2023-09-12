import React from 'react'
import { QueryClientProvider, useQueryClient } from '@tanstack/react-query'

export const TestQueryCache = ({
  children,
}: {
  children?: React.ReactNode
}): JSX.Element => {
  const queryClient = useQueryClient()

  return (
    <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
  )
}
