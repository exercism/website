// i18n-key-prefix: syntaxErrorView
// i18n-namespace: components/bootcamp/JikiscriptExercisePage/TestResultsView
import { GraphicalIcon } from '@/components/common/GraphicalIcon'
import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function SyntaxErrorView() {
  const { t } = useAppTranslation(
    'components/bootcamp/JikiscriptExercisePage/TestResultsView'
  )
  return (
    <div className="border-t-1 border-borderColor6">
      <div className="text-center py-40 px-40 max-w-[600px] mx-auto">
        <GraphicalIcon
          className={`w-[48px] h-[48px] m-auto mb-20 filter-textColor6`}
          icon="bug"
        />
        <div className="text-h5 mb-6 text-textColor6">
          {t('syntaxErrorView.oopsJikiCouldntUnderstand')}
        </div>
        <div className="mb-20 text-textColor6 leading-160 text-16 text-balance">
          {t('syntaxErrorView.noNeedToPanic')}
        </div>
      </div>
    </div>
  )
}
