import React, { useState, useEffect } from 'react'
import { useMutation } from 'react-query'
import { sendRequest } from '../../../../utils/send-request'
import { useIsMounted } from 'use-is-mounted'
import { Discussion, Relationship } from '../../FinishMentorDiscussionModal'
import { typecheck } from '../../../../utils/typecheck'
import { Loading } from '../../../common'
import { ErrorBoundary, useErrorHandler } from '../../../ErrorBoundary'

type SuccessFn = (relationship: Relationship) => void
type Choice = 'yes' | 'no'

const DEFAULT_ERROR = new Error('Unable to update student-mentor relationship')

const ErrorHandler = ({ error }: { error: unknown }) => {
  useErrorHandler(error, { defaultError: DEFAULT_ERROR })

  return null
}

export const MentorAgainStep = ({
  discussion,
  onYes,
  onNo,
}: {
  discussion: Discussion
  onYes: SuccessFn
  onNo: SuccessFn
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const [choice, setChoice] = useState<Choice | null>(null)
  const [mutate, { status, error }] = useMutation(
    () => {
      const method = choice === 'yes' ? 'DELETE' : 'POST'

      return sendRequest({
        endpoint: discussion.relationship.links.block,
        method: method,
        body: null,
        isMountedRef: isMountedRef,
      }).then((json) => {
        if (!json) {
          return
        }

        return typecheck<Relationship>(json, 'relationship')
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
      <p>Want to mentor {discussion.student.handle} again?</p>
      <button onClick={() => setChoice('yes')} disabled={status === 'loading'}>
        Yes
      </button>
      <button onClick={() => setChoice('no')} disabled={status === 'loading'}>
        No
      </button>
      {status === 'loading' ? <Loading /> : null}
      {status === 'error' ? (
        <ErrorBoundary>
          <ErrorHandler error={error} />
        </ErrorBoundary>
      ) : null}
    </div>
  )
}
