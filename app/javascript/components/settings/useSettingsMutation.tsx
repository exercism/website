import { useEffect, useCallback } from 'react'
import { useIsMounted } from 'use-is-mounted'
import { sendRequest } from '../../utils/send-request'
import { useMutation } from 'react-query'

export const useSettingsMutation = <T extends unknown>({
  endpoint,
  method,
  body,
  timeout = 3000,
  onSuccess = () => null,
}: {
  endpoint: string
  method: 'POST' | 'PATCH'
  body: T
  timeout?: number
  onSuccess?: () => void
}) => {
  const isMountedRef = useIsMounted()
  const [baseMutation, { status, error, reset }] = useMutation(
    () => {
      return sendRequest({
        endpoint: endpoint,
        method: method,
        body: JSON.stringify(body),
        isMountedRef: isMountedRef,
      })
    },
    {
      onSuccess: onSuccess,
    }
  )

  const mutation = useCallback(() => {
    reset()
    baseMutation()
  }, [baseMutation, reset])

  useEffect(() => {
    if (status !== 'success' && status !== 'error') {
      return
    }

    const timer = setTimeout(reset, timeout)

    return () => clearTimeout(timer)
  }, [reset, status, timeout])

  return { status, mutation, error }
}
