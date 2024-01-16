import { sendRequest } from '../../../utils/send-request'
import {
  MutationStatus,
  UseMutateFunction,
  useMutation,
} from '@tanstack/react-query'

export const useNotificationMutation = ({
  endpoint,
  body,
}: {
  endpoint: string
  body: { uuids: readonly string[] } | null
}): {
  mutation: UseMutateFunction
  status: MutationStatus
  error: unknown
} => {
  const {
    mutate: mutation,
    status,
    error,
  } = useMutation(async () => {
    const { fetch } = sendRequest({
      endpoint: endpoint,
      method: 'PATCH',
      body: JSON.stringify(body),
    })

    return fetch
  })

  return {
    mutation,
    status,
    error,
  }
}
