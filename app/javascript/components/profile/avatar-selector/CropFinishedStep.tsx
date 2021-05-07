import React, { useCallback } from 'react'
import { State, Action } from './reducer'
import { useMutation } from 'react-query'
import { typecheck } from '../../../utils/typecheck'
import { FormButton } from '../../common'
import { ResultsZone } from '../../ResultsZone'
import { ErrorBoundary, ErrorMessage } from '../../ErrorBoundary'
import { User } from '../../types'
import { camelizeKeys } from 'humps'

type Links = {
  update: string
}

const DEFAULT_ERROR = new Error('Unable to upload profile photo')

export const CropFinishedStep = ({
  state,
  dispatch,
  links,
}: {
  state: State
  dispatch: React.Dispatch<Action>
  links: Links
}): JSX.Element => {
  const [submit, { status, error }] = useMutation(
    () => {
      if (!state.croppedImage) {
        throw new Error('Cropped image was expected')
      }

      const formData = new FormData()
      formData.append('user[avatar]', state.croppedImage, 'avatar.jpg')

      /* TODO: Use our standard sendRequest library */
      return fetch(links.update, { body: formData, method: 'PATCH' })
        .then((response) => {
          return response.json().then((json) => camelizeKeys(json))
        })
        .then((json) => {
          return typecheck<User>(json, 'user')
        })
    },
    {
      onSuccess: (user) => {
        dispatch({
          type: 'avatar.uploaded',
          payload: { avatarUrl: user.avatarUrl },
        })
      },
    }
  )

  const handleRedo = useCallback(() => {
    dispatch({ type: 'crop.redo' })
  }, [dispatch])

  const handleSubmit = useCallback(() => {
    submit()
  }, [submit])

  return (
    <div>
      <ResultsZone isFetching={status === 'loading'}>
        <img src={URL.createObjectURL(state.croppedImage)} />
      </ResultsZone>
      <FormButton status={status} onClick={handleRedo}>
        Redo
      </FormButton>
      <FormButton status={status} onClick={handleSubmit}>
        Submit
      </FormButton>
      <ErrorBoundary>
        <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
      </ErrorBoundary>
    </div>
  )
}
