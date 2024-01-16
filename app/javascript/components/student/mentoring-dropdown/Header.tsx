import React from 'react'
import CopyToClipboardButton from '@/components/common/CopyToClipboardButton'
import type { SolutionMentoringStatus } from '@/components/types'

export const Header = ({
  mentoringStatus,
  shareLink,
}: {
  mentoringStatus: SolutionMentoringStatus
  shareLink: string
}): JSX.Element => {
  return mentoringStatus === 'in_progress' ? (
    <div className="discussion-in-progress">
      <h3>Mentoring currently in progress</h3>
      <p>Share links aren&apos;t available with active mentoring</p>
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
