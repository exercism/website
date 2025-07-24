import React from 'react'
import { GraphicalIcon } from '../../../common/GraphicalIcon'
import { Student } from '../../../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const FinishStep = ({
  student,
  onReset,
}: {
  student: Student
  onReset: () => void
}): JSX.Element => {
  const { t } = useAppTranslation(
    'components/mentoring/discussion/finished-wizard'
  )
  return (
    <div>
      {student.isFavorited ? (
        <p>
          {t('finishStep.isOneOfYourFavorites', {
            studentHandle: student.handle,
          })}
        </p>
      ) : student.isBlocked ? (
        <p>
          {t('finishStep.willNotSeeFutureRequests', {
            studentHandle: student.handle,
          })}
        </p>
      ) : (
        <p>
          {t('finishStep.thanksForMentoring', {
            studentHandle: student.handle,
          })}
        </p>
      )}
      <button
        className="btn-link-legacy"
        type="button"
        onClick={() => onReset()}
      >
        <GraphicalIcon icon="reset" />
        <span>{t('finishStep.changePreferences')}</span>
      </button>
    </div>
  )
}
