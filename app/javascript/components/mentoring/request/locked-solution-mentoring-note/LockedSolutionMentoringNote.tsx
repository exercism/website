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
    diff,
    diffMins,
    diffMinutes,
    extendModalOpen,
    setExtendModalOpen,
    extendLockedUntil,
    adjustOpenModalAt,
  } = useLockedSolutionMentoringNote(request)

  return (
    <>
      <div className="note">
        Check out our{' '}
        <a href={links.mentoringDocs} target="_blank" rel="noreferrer">
          mentoring docs
        </a>{' '}
        for more information.{' '}
        {diff > 0
          ? `This solution is locked until ${lockedUntil} (${diffMins} from now).`
          : 'This solution is no longer locked and another mentor may pick it up'}
      </div>
      <ExtendLockedUntilModal
        open={extendModalOpen}
        diffMinutes={diffMinutes}
        onClose={() => setExtendModalOpen(false)}
        onExtend={extendLockedUntil}
        adjustOpenModalAt={adjustOpenModalAt}
      />
    </>
  )
}
