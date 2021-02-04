import React from 'react'
import { useMutation } from 'react-query'
import { sendRequest } from '../../../../utils/send-request'
import { useIsMounted } from 'use-is-mounted'
import { Discussion, Relationship } from '../../EndSessionModal'
import { typecheck } from '../../../../utils/typecheck'

export const MentorAgainStep = ({
  discussion,
  onYes,
  onNo,
}: {
  discussion: Discussion
  onYes: (relationship: Relationship) => void
  onNo: (relationship: Relationship) => void
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const [handleYes] = useMutation(
    () => {
      return sendRequest({
        endpoint: discussion.relationship.links.mentorAgain,
        method: 'PATCH',
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

        onYes(relationship)
      },
    }
  )
  const [handleNo] = useMutation(
    () => {
      return sendRequest({
        endpoint: discussion.relationship.links.dontMentorAgain,
        method: 'PATCH',
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

        onNo(relationship)
      },
    }
  )

  return (
    <div>
      <p>Want to mentor {discussion.student.handle} again?</p>
      <button onClick={() => handleYes()}>Yes</button>
      <button onClick={() => handleNo()}>No</button>
    </div>
  )
}
