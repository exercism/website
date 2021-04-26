import React, { useState } from 'react'
import { FinishMentorDiscussionModal } from '../../modals/student/FinishMentorDiscussionModal'
import { MentorDiscussion } from '../../types'

type Links = {
  exercise: string
}

export const FinishButton = ({
  discussion,
  links,
}: {
  discussion: MentorDiscussion
  links: Links
}): JSX.Element => {
  const [open, setOpen] = useState(false)

  return (
    <React.Fragment>
      <button
        type="button"
        className="btn-keyboard-shortcut finish-button"
        onClick={() => {
          setOpen(true)
        }}
      >
        <div className="--hint">End discussion</div>
        <div className="--kb">F3</div>
      </button>
      <FinishMentorDiscussionModal
        discussion={discussion}
        links={links}
        open={open}
        onClose={() => {
          setOpen(false)
        }}
        onCancel={() => {
          setOpen(false)
        }}
      />
    </React.Fragment>
  )
}
