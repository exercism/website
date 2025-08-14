// i18n-key-prefix: stateTestResultView
// i18n-namespace: components/bootcamp/JikiscriptExercisePage/TestResultsView
import { GraphicalIcon } from '@/components/common'
import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function StateTestResultView({
  errorHtml,
  isPassing,
}: {
  errorHtml: string | undefined
  isPassing: boolean
}) {
  const { t } = useAppTranslation(
    'components/bootcamp/JikiscriptExercisePage/TestResultsView'
  )
  if (!errorHtml || isPassing) return null
  return (
    <div className="error-message">
      <GraphicalIcon icon="bootcamp-cross-red" />
      <div>
        <strong>{t('stateTestResultView.uhOh')}</strong>{' '}
        <span dangerouslySetInnerHTML={{ __html: errorHtml }} />
      </div>
    </div>
  )
}
