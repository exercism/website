import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { ExtendLockedUntilModal } from './ExtendLockedUntilModal'
import type { MentorSessionRequest } from '@/components/types'
import { useLockedSolutionMentoringNote } from './useLockedSolutionMentoringNote'
import { Trans } from 'react-i18next'

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
  const { t } = useAppTranslation(
    'components/mentoring/request/locked-solution-mentoring-note'
  )
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
        <Trans
          i18nKey={diff > 0 ? 'locked.stillLocked' : 'locked.unlocked'}
          ns="components/mentoring/request/locked-solution-mentoring-note"
          values={{ lockedUntil, diffMins }}
          components={{
            a: (
              <a href={links.mentoringDocs} target="_blank" rel="noreferrer" />
            ),
          }}
        />
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
