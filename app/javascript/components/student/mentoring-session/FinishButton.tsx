import React, { useState, useEffect } from 'react'
import { FinishMentorDiscussionModal } from '../../modals/student/FinishMentorDiscussionModal'
import { ConfirmFinishMentorDiscussionModal } from '../../modals/student/ConfirmFinishMentorDiscussionModal'
import { MentorDiscussion } from '../../types'
import Mousetrap from 'mousetrap'

type Links = {
  exercise: string
}

type Status = 'initialized' | 'confirming' | 'finishing'

export const FinishButton = ({
  discussion,
  className,
  children,
  links,
}: React.PropsWithChildren<{
  className: string
  discussion: MentorDiscussion
  links: Links
}>): JSX.Element => {
  const [status, setStatus] = useState<Status>('initialized')

  useEffect(() => {
    Mousetrap.bind('f3', () => {
      switch (status) {
        case 'initialized':
          setStatus('confirming')
          break
        case 'confirming':
          setStatus('finishing')
          break
      }
    })
    Mousetrap.bind('f2', () => {
      setStatus('initialized')
    })

    return () => {
      Mousetrap.unbind('f2')
      Mousetrap.unbind('f3')
    }
  }, [status])

  return (
    <React.Fragment>
      <button
        type="button"
        className={className}
        onClick={() => {
          setStatus('confirming')
        }}
      >
        {children}
      </button>
      <ConfirmFinishMentorDiscussionModal
        open={status === 'confirming'}
        onConfirm={() => {
          setStatus('finishing')
        }}
        onCancel={() => {
          setStatus('initialized')
        }}
      />
      <FinishMentorDiscussionModal
        discussion={discussion}
        links={links}
        open={status === 'finishing'}
        onClose={() => {
          setStatus('initialized')
        }}
        onCancel={() => {
          setStatus('initialized')
        }}
      />
    </React.Fragment>
  )
}
