import { useEffect, useCallback } from 'react'
import { useIsMounted } from 'use-is-mounted'
import { sendRequest } from '../../utils/send-request'
import { useMutation } from 'react-query'

export const useSettingsMutation = <
  T extends unknown,
  U extends unknown = void
>({
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
  onSuccess?: (params: U) => void
}) => {
  const isMountedRef = useIsMounted()
  const [baseMutation, { status, error, reset }] = useMutation<U>(
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
