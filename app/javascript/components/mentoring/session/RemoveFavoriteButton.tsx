import React, { useState } from 'react'
import { FormButton } from '../../common'
import { GraphicalIcon } from '../../common/GraphicalIcon'
import { useMutation } from 'react-query'
import { ErrorBoundary, useErrorHandler } from '../../ErrorBoundary'
import { sendRequest } from '../../../utils/send-request'
import { Student } from '../../types'
import { typecheck } from '../../../utils/typecheck'

type ComponentProps = {
  endpoint: string
  onSuccess: (student: Student) => void
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
  const [isHovering, setIsHovering] = useState(false)

  const [mutation, { status, error }] = useMutation<Student>(
    () => {
      const { fetch } = sendRequest({
        endpoint: endpoint,
        method: 'DELETE',
        body: null,
      })

      return fetch.then((json) => typecheck<Student>(json, 'student'))
    },
    {
      onSuccess: (student) => onSuccess(student),
    }
  )

  useErrorHandler(error, { defaultError: DEFAULT_ERROR })

  return (
    <FormButton
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
      status={status}
    >
      {isHovering ? (
        'Unfavorite?'
      ) : (
        <>
          <GraphicalIcon icon="star" />
          <span>Favorited</span>
        </>
      )}
    </FormButton>
  )
}
