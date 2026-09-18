import React, { useState } from 'react'
import { Trans } from 'react-i18next'
import { Icon } from '../common'
import { ExerciseUpdateModal } from '../modals/ExerciseUpdateModal'
import { useAppTranslation } from '@/i18n/useAppTranslation'

type Links = {
  diff: string
  english?: string
}

export default function UpdateExerciseNotice({
  links,
  docsForNewerVersion = false,
}: {
  links: Links
  docsForNewerVersion?: boolean
}): JSX.Element {
  const { t } = useAppTranslation('components/student/UpdateExerciseNotice.tsx')
  const [open, setOpen] = useState(false)
  return (
    <React.Fragment>
      {docsForNewerVersion ? (
        <div className="update-bar">
          <Icon icon="warning" alt="Warning" />
          <span>
            <Trans
              t={t}
              i18nKey="updateExerciseNotice.docsForNewerVersion"
              components={{
                english: <a href={links.english} hrefLang="en" />,
                update: (
                  <button
                    type="button"
                    className="text-prominentLinkColor"
                    onClick={() => setOpen(true)}
                  />
                ),
              }}
            />
          </span>
        </div>
      ) : (
        <button
          type="button"
          className="update-bar"
          onClick={() => setOpen(!open)}
        >
          <Icon icon="warning" alt="Warning" />
          {t('updateExerciseNotice.exerciseUpdated')}
          <div className="faux-link">
            {t('updateExerciseNotice.seeWhatsChanged')}
          </div>
        </button>
      )}
      <ExerciseUpdateModal
        endpoint={links.diff}
        open={open}
        onClose={() => setOpen(false)}
      />
    </React.Fragment>
  )
}
