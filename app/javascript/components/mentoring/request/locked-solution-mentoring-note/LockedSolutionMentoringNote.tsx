import React from 'react'
import { ExtendLockedUntilModal } from './ExtendLockedUntilModal'
import type { MentorSessionRequest } from '@/components/types'
import { useLockedSolutionMentoringNote } from './useLockedSolutionMentoringNote'

type Links = {
  mentoringDocs: string
}

export const LockedSolutionMentoringNote = ({
  links,
  request,
}: {
  links: Links
  request: MentorSessionRequest
}): JSX.Element => {
  const {
    lockedUntil,
    diffMins,
    diffMinutes,
    extendModalOpen,
    setExtendModalOpen,
    extendLockedUntil,
  } = useLockedSolutionMentoringNote(request)

  return (
    <>
      <div className="note">
        Check out our{' '}
        <a href={links.mentoringDocs} target="_blank" rel="noreferrer">
          mentoring docs
        </a>{' '}
        for more information. This solution is locked until {lockedUntil} (
        {diffMins} from now.)
      </div>
      <ExtendLockedUntilModal
        open={extendModalOpen}
        diffMinutes={diffMinutes}
        onClose={() => setExtendModalOpen(false)}
        onExtend={extendLockedUntil}
      />
    </>
  )
}
