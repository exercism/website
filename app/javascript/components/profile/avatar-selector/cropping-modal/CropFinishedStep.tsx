// i18n-key-prefix: cropFinishedStep
// i18n-namespace: components/profile/avatar-selector/cropping-modal
import React, { useCallback } from 'react'
import { useMutation } from '@tanstack/react-query'
import { camelizeKeys } from 'humps'
import { typecheck } from '@/utils/typecheck'
import { GraphicalIcon } from '@/components/common'
import { FormButton } from '@/components/common/FormButton'
import { ResultsZone } from '@/components/ResultsZone'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'
import { User } from '@/components/types'
import { State, Action } from '../use-image-crop'
import { useAppTranslation } from '@/i18n/useAppTranslation'

type Links = {
  update: string
}

const DEFAULT_ERROR = new Error('Unable to upload profile photo')

export const CropFinishedStep = ({
  state,
  dispatch,
  links,
  onUpload,
}: {
  state: State
  dispatch: React.Dispatch<Action>
  links: Links
  onUpload: (user: User) => void
}): JSX.Element => {
  const { t } = useAppTranslation(
    'components/profile/avatar-selector/cropping-modal'
  )

  const {
    mutate: submit,
    status,
    error,
  } = useMutation({
    mutationFn: async () => {
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
    onSuccess: (user) => {
      dispatch({
        type: 'avatar.uploaded',
        payload: { avatarUrl: user.avatarUrl },
      })

      onUpload(user)
    },
  })

  const handleRedo = useCallback(() => {
    dispatch({ type: 'crop.redo' })
  }, [dispatch])

  const handleSubmit = useCallback(() => {
    submit()
  }, [submit])

  return (
    <>
      <h3>{t('cropFinishedStep.happyWithResult')}</h3>
      <ResultsZone isFetching={status === 'pending'}>
        <img
          // @ts-expect-error URL.createObjectURL expect File or Blob meanwhile croppedImage can be null
          // TODO: fix this
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
          {t('cropFinishedStep.recrop')}
        </FormButton>
        <FormButton
          status={status}
          onClick={handleSubmit}
          className="btn-primary btn-s"
        >
          {t('cropFinishedStep.saveImage')}
        </FormButton>
      </div>
      <ErrorBoundary>
        <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
      </ErrorBoundary>
    </>
  )
}
