import React, { useState, useEffect } from 'react'
import { useMutation } from 'react-query'
import { sendRequest } from '../../../../utils/send-request'
import { useIsMounted } from 'use-is-mounted'
import { typecheck } from '../../../../utils/typecheck'
import { Loading } from '../../../common'
import { GraphicalIcon } from '../../../common/GraphicalIcon'
import { ErrorBoundary, useErrorHandler } from '../../../ErrorBoundary'
import { Student } from '../../Session'

type SuccessFn = (student: Student) => void
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
  student: Student
  onYes: SuccessFn
  onNo: SuccessFn
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const [choice, setChoice] = useState<Choice | null>(null)
  const [mutate, { status, error }] = useMutation(
    () => {
      const method = choice === 'yes' ? 'DELETE' : 'POST'

      return sendRequest({
        endpoint: student.links.block,
        method: method,
        body: null,
        isMountedRef: isMountedRef,
      }).then((json) => {
        if (!json) {
          return
        }

        return typecheck<Student>(json, 'student')
      })
    },
    {
      onSuccess: (student) => {
        if (!student) {
          return
        }

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
