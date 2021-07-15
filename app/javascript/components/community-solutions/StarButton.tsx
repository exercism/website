import React, { useState } from 'react'
import { FormButton, Icon } from '../common'
import { useMutation } from 'react-query'
import { sendRequest } from '../../utils/send-request'
import { typecheck } from '../../utils/typecheck'
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
  const [state, setState] = useState({
    numStars: defaultNumStars,
    isStarred: defaultIsStarred,
  })
  const [mutation, { status, error }] = useMutation<APIResponse>(
    () => {
      const { fetch } = sendRequest({
        endpoint: links.star,
        method: state.isStarred ? 'DELETE' : 'POST',
        body: null,
      })

      return fetch.then((json) => typecheck<APIResponse>(json, 'star'))
    },
    {
      onSuccess: (response) => {
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
