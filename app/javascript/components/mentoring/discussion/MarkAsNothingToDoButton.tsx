import React from 'react'
import { useMutation } from 'react-query'
import { Loading } from '../../common'

export const MarkAsNothingToDoButton = ({
  endpoint,
}: {
  endpoint: string
}): JSX.Element | null => {
  const [mutation, { status }] = useMutation(() => {
    return fetch(endpoint, { method: 'PATCH' })
  })

  switch (status) {
    case 'idle':
      return (
        <button
          onClick={() => {
            mutation()
          }}
          type="button"
        >
          Mark as nothing to do
        </button>
      )
    case 'loading':
      return <Loading />
    default:
      return null
  }
}
