import React, { useState } from 'react'
import { Loading } from '../../common'
import { GraphicalIcon } from '../../common/GraphicalIcon'
import { useMutation } from 'react-query'
import { ErrorBoundary, useErrorHandler } from '../../ErrorBoundary'
import { useIsMounted } from 'use-is-mounted'
import { sendRequest } from '../../../utils/send-request'
import { Student } from '../Session'

type ComponentProps = {
  endpoint: string
  onSuccess: (student: Student) => void
}

type APIResponse = {
  student: Student
}

export const RemoveFavoriteButton = (props: ComponentProps): JSX.Element => {
  return (
    <ErrorBoundary>
      <Component {...props} />
    </ErrorBoundary>
  )
}

const DEFAULT_ERROR = new Error('Unable to remove student as a favorite')

const Component = ({
  endpoint,
  onSuccess,
  ...props
}: ComponentProps): JSX.Element | null => {
  const isMountedRef = useIsMounted()
  const [isHovering, setIsHovering] = useState(false)

  const [mutation, { status, error }] = useMutation<APIResponse>(
    () => {
      return sendRequest({
        endpoint: endpoint,
        method: 'DELETE',
        body: null,
        isMountedRef: isMountedRef,
      })
    },
    {
      onSuccess: (response) => onSuccess(response.student),
    }
  )

  useErrorHandler(error, { defaultError: DEFAULT_ERROR })

  switch (status) {
    case 'idle':
      return (
        <button
          {...props}
          onClick={() => {
            mutation()
          }}
          type="button"
          className={
            // We use a hover class, rather than the hover css construct
            // so that the button doesn't immediately switch to its hover
            // state once it's been clicked. By using onMouseEnter that state
            // only gets set when someone is moving into the box afresh.
            'btn-small unfavorite-button ' + (isHovering ? 'hover' : '')
          }
          // TODO: These do not work on tab (a11y).
          // When tabbing this should be set to true.
          onMouseEnter={() => setIsHovering(true)}
          onMouseLeave={() => setIsHovering(false)}
        >
          {isHovering ? (
            'Unfavorite?'
          ) : (
            <>
              <GraphicalIcon icon="star" />
              <span>Favorited</span>
            </>
          )}
        </button>
      )
    case 'loading':
      return <Loading />
    default:
      return null
  }
}
