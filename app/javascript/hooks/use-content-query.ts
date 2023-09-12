import { useRequestQuery } from '../hooks/request-query'

export function useContentQuery(
  id: string,
  endpoint: string,
  enabled: boolean
): {
  isLoading: boolean
  isError: boolean
  htmlContent: { html: string } | undefined
} {
  const {
    isLoading,
    isError,
    data: htmlContent,
  } = useRequestQuery<{
    html: string
  }>([id], { endpoint: endpoint, options: { enabled } })

  return { isLoading, isError, htmlContent }
}
