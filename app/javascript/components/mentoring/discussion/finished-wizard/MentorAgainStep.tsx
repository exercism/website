import React, { useState, useEffect } from 'react'
import { useMutation } from 'react-query'
import { sendRequest } from '../../../../utils/send-request'
import { useIsMounted } from 'use-is-mounted'
import { typecheck } from '../../../../utils/typecheck'
import { Loading } from '../../../common'
import { GraphicalIcon } from '../../../common/GraphicalIcon'
import { ErrorBoundary, useErrorHandler } from '../../../ErrorBoundary'
import { Partner, StudentMentorRelationship } from '../../Session'

type SuccessFn = (relationship: StudentMentorRelationship) => void
type Choice = 'yes' | 'no'

const DEFAULT_ERROR = new Error('Unable to update student-mentor relationship')

const ErrorHandler = ({ error }: { error: unknown }) => {
  useErrorHandler(error, { defaultError: DEFAULT_ERROR })

  return null
}

export const MentorAgainStep = ({
  student,
  relationship,
  onYes,
  onNo,
}: {
  student: Partner
  relationship: StudentMentorRelationship
  onYes: SuccessFn
  onNo: SuccessFn
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const [choice, setChoice] = useState<Choice | null>(null)
  const [mutate, { status, error }] = useMutation(
    () => {
      const method = choice === 'yes' ? 'DELETE' : 'POST'

      return sendRequest({
        endpoint: relationship.links.block,
        method: method,
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

        choice === 'yes' ? onYes(relationship) : onNo(relationship)
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
      <p>Want to mentor {student.handle} again?</p>
      <div className="buttons">
        <button
          className="btn-small"
          onClick={() => setChoice('yes')}
          disabled={status === 'loading'}
        >
          <GraphicalIcon icon="checkmark" />
          Yes
        </button>
        <button
          className="btn-small"
          onClick={() => setChoice('no')}
          disabled={status === 'loading'}
        >
          <GraphicalIcon icon="cross" />
          No
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
