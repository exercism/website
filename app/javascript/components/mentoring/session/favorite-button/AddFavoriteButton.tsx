import React from 'react'
import { useMutation } from 'react-query'
import { sendRequest } from '@/utils/send-request'
import { GraphicalIcon } from '@/components/common/GraphicalIcon'
import { ErrorBoundary, useErrorHandler } from '@/components/ErrorBoundary'
import { FavoritableStudent } from '../FavoriteButton'
import { FormButton } from '@/components/common/FormButton'
import { typecheck } from '@/components/../utils/typecheck'

type ComponentProps = {
  endpoint: string
  onSuccess: (student: FavoritableStudent) => void
}

export const AddFavoriteButton = (props: ComponentProps): JSX.Element => {
  return (
    <ErrorBoundary>
      <Component {...props} />
    </ErrorBoundary>
  )
}

const DEFAULT_ERROR = new Error('Unable to mark student as a favorite')

const Component = ({
  endpoint,
  onSuccess,
}: ComponentProps): JSX.Element | null => {
  const [mutation, { status, error }] = useMutation<FavoritableStudent>(
    () => {
      const { fetch } = sendRequest({
        endpoint: endpoint,
        method: 'POST',
        body: null,
      })

      return fetch.then((json) =>
        typecheck<FavoritableStudent>(json, 'student')
      )
    },
    {
      onSuccess: (student) => onSuccess(student),
    }
  )

  /* TODO: (required) Style this */
  useErrorHandler(error, { defaultError: DEFAULT_ERROR })

  return (
    <FormButton
      onClick={() => {
        mutation()
      }}
      type="button"
      className="btn-small"
      status={status}
    >
      <GraphicalIcon icon="plus" />
      <span>Add to favorites</span>
    </FormButton>
  )
}
