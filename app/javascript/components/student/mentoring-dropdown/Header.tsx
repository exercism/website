import React from 'react'
import CopyToClipboardButton from '@/components/common/CopyToClipboardButton'
import type { SolutionMentoringStatus } from '@/components/types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const Header = ({
  mentoringStatus,
  shareLink,
}: {
  mentoringStatus: SolutionMentoringStatus
  shareLink: string
}): JSX.Element => {
  const { t } = useAppTranslation()

  return mentoringStatus === 'in_progress' ? (
    <div className="discussion-in-progress">
      <h3>{t('header.mentoringCurrentlyInProgress')}</h3>
      <p>{t('header.shareLinksNotAvailable')}</p>
    </div>
  ) : (
    <div className="mentoring-request">
      <h3>{t('header.wantToGetMentored')}</h3>
      <p>{t('header.inviteFriendsColleagues')}</p>
      <CopyToClipboardButton textToCopy={shareLink} />
    </div>
  )
}
