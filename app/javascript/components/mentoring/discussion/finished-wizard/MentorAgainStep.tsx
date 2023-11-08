import React, { useState, useEffect } from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '../../../../utils/send-request'
import { typecheck } from '../../../../utils/typecheck'
import { Loading } from '../../../common'
import { GraphicalIcon } from '../../../common/GraphicalIcon'
import { ErrorBoundary, useErrorHandler } from '../../../ErrorBoundary'
import { FavoritableStudent } from '../../session/FavoriteButton'

type SuccessFn = (student: FavoritableStudent) => void
type Choice = 'yes' | 'no'

const DEFAULT_ERROR = new Error('Unable to update student')

const ErrorHandler = ({ error }: { error: unknown }) => {
  useErrorHandler(error, { defaultError: DEFAULT_ERROR })

  return null
}

export const MentorAgainStep = ({
  student,
  onYes,
  onNo,
}: {
  student: FavoritableStudent
  onYes: SuccessFn
  onNo: SuccessFn
}): JSX.Element => {
  const [choice, setChoice] = useState<Choice | null>(null)
  const {
    mutate: mutate,
    status,
    error,
  } = useMutation<FavoritableStudent>(
    async () => {
      const method = choice === 'yes' ? 'DELETE' : 'POST'

      const { fetch } = sendRequest({
        endpoint: student.links.block,
        method: method,
        body: null,
      })

      return fetch.then((json) =>
        typecheck<FavoritableStudent>(json, 'student')
      )
    },
    {
      onSuccess: (student) => {
        choice === 'yes' ? onYes(student) : onNo(student)
      },
    }
  )

  useEffect(() => {
    if (!choice) {
      return
    }

    mutate()
  }, [choice, mutate])

  return (
    <div>
      <p>Do you want to mentor {student.handle} again?</p>
      <div className="buttons">
        <button
          className="btn-small"
          onClick={() => setChoice('yes')}
          disabled={status === 'loading'}
        >
          <GraphicalIcon icon="checkmark" />
          <span>Yes</span>
        </button>
        <button
          className="btn-small"
          onClick={() => setChoice('no')}
          disabled={status === 'loading'}
        >
          <GraphicalIcon icon="cross" />
          <span>No</span>
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
