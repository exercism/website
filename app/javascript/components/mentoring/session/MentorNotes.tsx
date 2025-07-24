import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

function PrLink({ improveUrl }: { improveUrl: string }): JSX.Element {
  const { t } = useAppTranslation('session-batch-3')
  return (
    <a href={improveUrl} target="_blank" rel="noreferrer">
      {t('components.mentoring.session.mentorNotes.pullRequestOnGithub')}
    </a>
  )
}

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

  if (!notes) {
    return (
      <p className="text-p-base">
        <Trans
          ns="session-batch-3"
          i18nKey="components.mentoring.session.mentorNotes.noNotesYet"
          components={{
            prLink: <PrLink improveUrl={improveUrl} />,
          }}
          values={{ guidanceType }}
        />
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
        <Trans
          ns="session-batch-3"
          i18nKey="components.mentoring.session.mentorNotes.communityNotes"
          components={{
            prLink: <PrLink improveUrl={improveUrl} />,
          }}
        />
      </p>
    </React.Fragment>
  )
}
