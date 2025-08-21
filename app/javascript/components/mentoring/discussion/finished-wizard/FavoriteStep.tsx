import React from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '../../../../utils/send-request'
import { typecheck } from '../../../../utils/typecheck'
import { Loading } from '../../../common'
import { GraphicalIcon } from '../../../common/GraphicalIcon'
import { ErrorBoundary, useErrorHandler } from '../../../ErrorBoundary'
import { FavoritableStudent } from '../../session/FavoriteButton'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const DEFAULT_ERROR = new Error('Unable to mark student as a favorite')

const ErrorHandler = ({ error }: { error: unknown }) => {
  useErrorHandler(error, { defaultError: DEFAULT_ERROR })

  return null
}

export const FavoriteStep = ({
  student,
  onFavorite,
  onSkip,
}: {
  student: FavoritableStudent
  onFavorite: (student: FavoritableStudent) => void
  onSkip: () => void
}): JSX.Element => {
  const { t } = useAppTranslation(
    'components/mentoring/discussion/finished-wizard'
  )
  const {
    mutate: handleFavorite,
    status,
    error,
  } = useMutation<FavoritableStudent>({
    mutationFn: async () => {
      const { fetch } = sendRequest({
        endpoint: student.links.favorite,
        method: 'POST',
        body: null,
      })

      return fetch.then((json) =>
        typecheck<FavoritableStudent>(json, 'student')
      )
    },
    onSuccess: (student) => {
      if (!onFavorite) {
        return
      }

      onFavorite(student)
    },
  })

  return (
    <div>
      <p>
        {t('favoriteStep.addStudentToFavorites', {
          studentHandle: student.handle,
        })}
      </p>
      <div className="buttons">
        <button
          className="btn-small"
          type="button"
          onClick={() => handleFavorite()}
          disabled={status === 'pending'}
        >
          <GraphicalIcon icon="plus" />
          {t('favoriteStep.addToFavorites')}
        </button>
        <button
          className="btn-small"
          type="button"
          onClick={() => onSkip()}
          disabled={status === 'pending'}
        >
          {t('favoriteStep.skip')}
        </button>
      </div>
      {status === 'pending' ? <Loading /> : null}
      {status === 'error' ? (
        <ErrorBoundary>
          <ErrorHandler error={error} />
        </ErrorBoundary>
      ) : null}
    </div>
  )
}
