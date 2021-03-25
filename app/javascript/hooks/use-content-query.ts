import { useRequestQuery } from '../hooks/request-query'
import { useIsMounted } from 'use-is-mounted'

export function useContentQuery(
  id: string,
  endpoint: string,
  enabled: boolean
): {
  isLoading: boolean
  isError: boolean
  htmlContent: { html: string } | undefined
} {
  const isMountedRef = useIsMounted()
  const { isLoading, isError, data: htmlContent } = useRequestQuery<{
    html: string
  }>(id, { endpoint: endpoint, options: { enabled } }, isMountedRef)

  return { isLoading, isError, htmlContent }
}
