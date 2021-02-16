import React from 'react'
import { useMutation } from 'react-query'
import { sendRequest } from '../../../../utils/send-request'
import { useIsMounted } from 'use-is-mounted'
import { typecheck } from '../../../../utils/typecheck'
import { Loading } from '../../../common'
import { GraphicalIcon } from '../../../common/GraphicalIcon'
import { ErrorBoundary, useErrorHandler } from '../../../ErrorBoundary'
import { Partner, StudentMentorRelationship } from '../../Session'

const DEFAULT_ERROR = new Error('Unable to mark student as a favorite')

const ErrorHandler = ({ error }: { error: unknown }) => {
  useErrorHandler(error, { defaultError: DEFAULT_ERROR })

  return null
}

export const FavoriteStep = ({
  student,
  relationship,
  onFavorite,
  onSkip,
}: {
  student: Partner
  relationship: StudentMentorRelationship
  onFavorite: (relationship: StudentMentorRelationship) => void
  onSkip: () => void
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const [handleFavorite, { status, error }] = useMutation(
    () => {
      return sendRequest({
        endpoint: relationship.links.favorite,
        method: 'POST',
        body: null,
        isMountedRef: isMountedRef,
      }).then((json) => {
        if (!json) {
          return
        }

        return typecheck<StudentMentorRelationship>(json, 'relationship')
      })
    },
    {
      onSuccess: (relationship) => {
        if (!relationship) {
          return
        }

        onFavorite(relationship)
      },
    }
  )

  return (
    <div>
      <p>Add {student.handle} to your favorites?</p>
      <div className="buttons">
        <button
          className="btn-small"
          type="button"
          onClick={() => handleFavorite()}
          disabled={status === 'loading'}
        >
          <GraphicalIcon icon="plus" />
          Add to favorites
        </button>
        <button
          className="btn-small"
          type="button"
          onClick={() => onSkip()}
          disabled={status === 'loading'}
        >
          Skip
        </button>
      </div>
      {status === 'loading' ? <Loading /> : null}
      {status === 'error' ? (
        <ErrorBoundary>
          <ErrorHandler error={error} />
        </ErrorBoundary>
      ) : null}
    </div>
  )
}
