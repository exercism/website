import React, { useState } from 'react'
import { FormButton, Icon } from '../common'
import { useMutation } from 'react-query'
import { sendRequest } from '../../utils/send-request'
import { typecheck } from '../../utils/typecheck'
import { useIsMounted } from 'use-is-mounted'
import { ErrorBoundary, ErrorMessage } from '../ErrorBoundary'

type Links = {
  star: string
}

type APIResponse = {
  isStarred: boolean
  numStars: number
}

const DEFAULT_ERROR = new Error('Unable to update stars')

export const StarButton = ({
  defaultNumStars,
  defaultIsStarred,
  links,
}: {
  defaultNumStars: number
  defaultIsStarred: boolean
  links: Links
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const [state, setState] = useState({
    numStars: defaultNumStars,
    isStarred: defaultIsStarred,
  })
  const [mutation, { status, error }] = useMutation(
    () => {
      return sendRequest({
        endpoint: links.star,
        method: state.isStarred ? 'DELETE' : 'POST',
        body: null,
        isMountedRef: isMountedRef,
      }).then((json) => {
        if (!json) {
          return
        }

        return typecheck<APIResponse>(json, 'star')
      })
    },
    {
      onSuccess: (response) => {
        if (!response) {
          return
        }

        setState(response)
      },
    }
  )

  return (
    <React.Fragment>
      <FormButton
        className={`btn-enhanced btn-s star-button --${
          state.isStarred ? 'starred' : 'unstarred'
        }`}
        type="button"
        onClick={() => mutation()}
        status={status}
      >
        <Icon
          icon={state.isStarred ? 'starred' : 'star'}
          alt="Number of stars"
        />
        <span>{state.numStars}</span>
      </FormButton>
      {status === 'error' ? (
        <ErrorBoundary>
          <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
        </ErrorBoundary>
      ) : null}
    </React.Fragment>
  )
}
