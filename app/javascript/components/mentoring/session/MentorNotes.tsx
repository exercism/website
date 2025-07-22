import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const MentorNotes = ({
  notes,
  improveUrl,
  guidanceType,
}: {
  notes?: string
  improveUrl: string
  guidanceType: 'track' | 'exercise' | 'representer'
}): JSX.Element => {
  const { t } = useAppTranslation('session-batch-3')
  const prLink = (
    <a href={improveUrl} target="_blank" rel="noreferrer">
      Pull Request on GitHub
    </a>
  )

  if (!notes) {
    return (
      <p className="text-p-base">
        {t('components.mentoring.session.mentorNotes.noNotesYet', {
          guidanceType: guidanceType,
          prLink: prLink,
        })}
      </p>
    )
  }

  return (
    <React.Fragment>
      <div
        className="c-textual-content --small"
        dangerouslySetInnerHTML={{ __html: notes }}
      />
      <hr className="c-divider --small my-16" />
      <h3 className="text-h5 mb-4">
        {t('components.mentoring.session.mentorNotes.improveNotes')}
      </h3>
      <p className="text-p-base">
        {t('components.mentoring.session.mentorNotes.communityNotes', {
          prLink: prLink,
        })}
      </p>
    </React.Fragment>
  )
}
