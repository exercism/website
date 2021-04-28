import React from 'react'
import { useMutation } from 'react-query'
import { useIsMounted } from 'use-is-mounted'
import { sendPostRequest } from '../../../utils/send-request'
import { Loading } from '../../common/Loading'
import { GraphicalIcon } from '../../common/GraphicalIcon'
import { ErrorBoundary, useErrorHandler } from '../../ErrorBoundary'
import { Student } from '../Session'

type ComponentProps = {
  endpoint: string
  onSuccess: (student: Student) => void
}

type APIResponse = {
  student: Student
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
  const isMountedRef = useIsMounted()
  const [mutation, { status, error }] = useMutation<APIResponse>(
    () => {
      return sendPostRequest({
        endpoint: endpoint,
        body: null,
        isMountedRef: isMountedRef,
      })
    },
    {
      onSuccess: (response) => onSuccess(response.student),
    }
  )

  /* TODO: Style this */
  useErrorHandler(error, { defaultError: DEFAULT_ERROR })

  switch (status) {
    case 'idle':
      return (
        <button
          onClick={() => {
            mutation()
          }}
          type="button"
          className="btn-small"
        >
          <GraphicalIcon icon="plus" />
          <span>Add to favorites</span>
        </button>
      )
    case 'loading':
      return <Loading />
    default:
      return null
  }
}
