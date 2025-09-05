// i18n-key-prefix:
// i18n-namespace: components/student/RequestMentoringButton.tsx
import React, { useState } from 'react'
import { RequestMentoringModal } from '../modals/RequestMentoringModal'
import { Request } from '../../hooks/request-query'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export type Links = {
  mentorRequest: string
}

export default function RequestMentoringButton({
  request,
  links,
}: {
  request: Request
  links: Links
}): JSX.Element {
  const [open, setOpen] = useState(false)
  const { t } = useAppTranslation()

  return (
    <React.Fragment>
      <button
        type="button"
        onClick={() => setOpen(true)}
        className="available-slot"
      >
        <h4>{t('mentoringSlotAvailable')}</h4>
        <div className="btn-simple">{t('selectAnExercise')}</div>
      </button>
      <RequestMentoringModal
        open={open}
        onClose={() => setOpen(false)}
        request={request}
        links={links}
      />
    </React.Fragment>
  )
}
