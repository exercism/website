import { sendRequest } from '../../../utils/send-request'
import { useMutation } from 'react-query'

export const useNotificationMutation = ({
  endpoint,
  body,
}: {
  endpoint: string
  body: { uuids: readonly string[] } | null
}) => {
  const [mutation, { status, error }] = useMutation(() => {
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
