import React, { useCallback } from 'react'
import { State, Action } from './reducer'
import { useMutation } from 'react-query'
import { typecheck } from '../../../utils/typecheck'
import { FormButton, GraphicalIcon } from '../../common'
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

      /* TODO: (optional) Use our standard sendRequest library */
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
    <>
      <h3>Happy with the result?</h3>
      <ResultsZone isFetching={status === 'loading'}>
        <img
          src={URL.createObjectURL(state.croppedImage)}
          className="cropped-image"
        />
      </ResultsZone>
      <div className="btns">
        <FormButton
          status={status}
          onClick={handleRedo}
          className="btn-default btn-s"
        >
          <GraphicalIcon icon="reset" />
          Recrop
        </FormButton>
        <FormButton
          status={status}
          onClick={handleSubmit}
          className="btn-primary btn-s"
        >
          Save image
        </FormButton>
      </div>
      <ErrorBoundary>
        <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
      </ErrorBoundary>
    </>
  )
}
