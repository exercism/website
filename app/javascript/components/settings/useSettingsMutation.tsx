import { useEffect, useCallback } from 'react'
import { sendRequest } from '../../utils/send-request'
import { MutationStatus, useMutation } from '@tanstack/react-query'

export const useSettingsMutation = <
  T extends unknown,
  U extends unknown = void
>({
  endpoint,
  method,
  body,
  timeout = 4000,
  onSuccess = () => null,
  onError,
}: {
  endpoint: string
  method: 'POST' | 'PATCH'
  body: T
  timeout?: number
  onSuccess?: (params: U) => void
  onError?: (error: unknown) => void
}): {
  status: MutationStatus
  mutation: () => void
  error: unknown
} => {
  const {
    mutate: baseMutation,
    status,
    error,
    reset,
  } = useMutation<U>(
    async () => {
      const { fetch } = sendRequest({
        endpoint: endpoint,
        method: method,
        body: JSON.stringify(body),
      })

      return fetch
    },
    {
      onSuccess,
      onError,
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
