import { sendRequest } from '../../../utils/send-request'
import { useMutation } from 'react-query'

export const useNotificationMutation = (endpoint: string) => {
  const [mutation, { status, error }] = useMutation<
    unknown,
    unknown,
    { uuids: readonly string[] }
  >(({ uuids }) => {
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
