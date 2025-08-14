// i18n-key-prefix: unhandledErrorView
// i18n-namespace: components/bootcamp/JikiscriptExercisePage/TestResultsView
import React from 'react'
import { GraphicalIcon } from '@/components/common/GraphicalIcon'
import CopyToClipboardButton from '@/components/common/CopyToClipboardButton'
import useErrorStore from '../store/errorStore'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function UnhandledErrorView() {
  const { t } = useAppTranslation(
    'components/bootcamp/JikiscriptExercisePage/TestResultsView'
  )
  const { unhandledErrorBase64 } = useErrorStore()
  return (
    <div className="border-t-1 border-borderColor6">
      <div className="text-center py-40 px-40 max-w-[600px] mx-auto">
        <GraphicalIcon
          className={`w-[48px] h-[48px] m-auto mb-20 filter-textColor6`}
          icon="bug"
        />
        <div className="text-h5 mb-6 text-textColor6">
          {t('unhandledErrorView.oopsSomethingWentWrong')}
        </div>
        <div className="mb-20 text-textColor6 leading-160 text-16 text-balance">
          {t('unhandledErrorView.helpfulInfo')}
        </div>
        <CopyToClipboardButton textToCopy={unhandledErrorBase64} />
      </div>
    </div>
  )
}
