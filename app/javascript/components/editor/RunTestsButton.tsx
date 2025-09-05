import React, { forwardRef } from 'react'
import { GraphicalIcon } from '../common/GraphicalIcon'
import { GenericTooltip } from '../misc/ExercismTippy'
import { useAppTranslation } from '@/i18n/useAppTranslation'

type Props = {
  haveFilesChanged: boolean
  isProcessing: boolean
} & React.ButtonHTMLAttributes<HTMLButtonElement>

export const RunTestsButton = forwardRef<HTMLButtonElement, Props>(
  ({ haveFilesChanged, isProcessing, ...props }, ref) => {
    const { t } = useAppTranslation()
    const isDisabled = !haveFilesChanged || isProcessing

    return (
      <GenericTooltip
        disabled={!isDisabled}
        content={t('runTestsButton.youHaveNotMadeChanges')}
      >
        <div className="run-tests-btn">
          <button
            type="button"
            className="btn-enhanced btn-s"
            disabled={isDisabled}
            ref={ref}
            {...props}
          >
            <GraphicalIcon icon="run-tests" />
            <span>{t('runTestsButton.runTests')}</span>
          </button>
        </div>
      </GenericTooltip>
    )
  }
)
