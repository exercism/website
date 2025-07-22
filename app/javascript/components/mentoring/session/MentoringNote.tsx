import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

type Links = {
  mentoringDocs: string
}

export const MentoringNote = ({ links }: { links: Links }): JSX.Element => {
  useAppTranslation('session-batch-3')
  return (
    <div className="note">
      <Trans
        i18nKey="components.mentoring.session.mentoringNote.mentoringDocs"
        components={{
          a: <a href={links.mentoringDocs} target="_blank" rel="noreferrer" />,
        }}
      />
    </div>
  )
}
