import React from 'react'
import { CopyToClipboardButton } from '../../common'

export const Header = ({
  hasMentorDiscussionInProgress,
  shareLink,
}: {
  hasMentorDiscussionInProgress: boolean
  shareLink: string
}): JSX.Element => {
  return hasMentorDiscussionInProgress ? (
    <div className="discussion-in-progress">
      <h3>Mentoring currently in progress</h3>
      <p>Share links aren’t available with active mentoring</p>
    </div>
  ) : (
    <div className="mentoring-request">
      <h3>Want to get mentored by a friend?</h3>
      <p>
        Use this share link to invite friends, colleagues or personal mentors
        directly to mentor your solution.
      </p>
      <CopyToClipboardButton textToCopy={shareLink} />
    </div>
  )
}
