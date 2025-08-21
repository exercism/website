import React, { useState } from 'react'
import { Icon } from '../common'
import { ExerciseUpdateModal } from '../modals/ExerciseUpdateModal'
import { useAppTranslation } from '@/i18n/useAppTranslation'

type Links = {
  diff: string
}

export default function UpdateExerciseNotice({
  links,
}: {
  links: Links
}): JSX.Element {
  const { t } = useAppTranslation('components/student/UpdateExerciseNotice.tsx')
  const [open, setOpen] = useState(false)
  return (
    <React.Fragment>
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
      <ExerciseUpdateModal
        endpoint={links.diff}
        open={open}
        onClose={() => setOpen(false)}
      />
    </React.Fragment>
  )
}
