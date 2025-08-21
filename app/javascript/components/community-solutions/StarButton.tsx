import React, { useState } from 'react'
import { useMutation } from '@tanstack/react-query'
import { GraphicalIcon, Icon } from '@/components/common'
import { FormButton } from '@/components/common/FormButton'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'
import { typecheck } from '@/utils'
import { sendRequest } from '@/utils/send-request'

type Links = {
  star: string
}

type APIResponse = {
  isStarred: boolean
  numStars: number
}

const DEFAULT_ERROR = new Error('Unable to update stars')

export default function StarButton({
  userSignedIn,
  defaultNumStars,
  defaultIsStarred,
  links,
}: {
  userSignedIn: boolean
  defaultNumStars: number
  defaultIsStarred: boolean
  links: Links
}): JSX.Element {
  const [state, setState] = useState({
    numStars: defaultNumStars,
    isStarred: defaultIsStarred,
  })
  const {
    mutate: mutation,
    status,
    error,
  } = useMutation<APIResponse>({
    mutationFn: async () => {
      const { fetch } = sendRequest({
        endpoint: links.star,
        method: state.isStarred ? 'DELETE' : 'POST',
        body: null,
      })

      return fetch.then((json) => typecheck<APIResponse>(json, 'star'))
    },
    onSuccess: (response) => {
      setState(response)
    },
  })

  if (!userSignedIn) {
    return (
      <div className="btn-enhanced btn-s star-button --unstarred">
        <Icon icon="star" alt="Number of stars" />
        <span>Favorite</span>
      </div>
    )
  }

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
        <GraphicalIcon icon={state.isStarred ? 'starred' : 'star'} />
        <span>{state.isStarred ? 'Favorited' : 'Favorite'}</span>
      </FormButton>
      {status === 'error' ? (
        <ErrorBoundary>
          <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
        </ErrorBoundary>
      ) : null}
    </React.Fragment>
  )
}
