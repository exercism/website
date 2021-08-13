import { sendRequest } from '../../../utils/send-request'
import { useMutation } from 'react-query'

export const useNotificationMutation = ({
  endpoint,
  uuids,
}: {
  endpoint: string
  uuids: readonly string[]
}) => {
  const [mutation, { status, error }] = useMutation(() => {
    const { fetch } = sendRequest({
      endpoint: endpoint,
      method: 'PATCH',
      body: JSON.stringify({ uuids: uuids }),
    })

    return fetch
  })

  return {
    mutation,
    status,
    error,
  }
}
