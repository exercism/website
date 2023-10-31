import React, { useState } from 'react'
import { useMutation } from '@tanstack/react-query'
import { FormButton } from '@/components/common/FormButton'
import { GraphicalIcon } from '@/components/common/GraphicalIcon'
import { ErrorBoundary, useErrorHandler } from '@/components/ErrorBoundary'
import { sendRequest } from '@/utils/send-request'
import { FavoritableStudent } from '../FavoriteButton'
import { typecheck } from '@/utils/typecheck'

type ComponentProps = {
  endpoint: string
  onSuccess: (student: FavoritableStudent) => void
  isRemoveButtonHoverable: boolean
  setIsRemoveButtonHoverable: React.Dispatch<React.SetStateAction<boolean>>
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
  isRemoveButtonHoverable,
  setIsRemoveButtonHoverable,
  ...props
}: ComponentProps): JSX.Element | null => {
  const [isHovering, setIsHovering] = useState(false)

  const {
    mutate: mutation,
    status,
    error,
  } = useMutation<FavoritableStudent>(
    async () => {
      const { fetch } = sendRequest({
        endpoint: endpoint,
        method: 'DELETE',
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
      // TODO: (required) These do not work on tab (a11y).
      // When tabbing this should be set to true.
      onMouseEnter={() => {
        if (isRemoveButtonHoverable) {
          setIsHovering(true)
        }
      }}
      onMouseLeave={() => {
        setIsHovering(false)
        setIsRemoveButtonHoverable(true)
      }}
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
