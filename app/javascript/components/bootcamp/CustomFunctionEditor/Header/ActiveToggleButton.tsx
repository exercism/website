import React from 'react'
import { ToggleButton } from '@/components/common/ToggleButton'
import { StaticTooltip } from '../../JikiscriptExercisePage/Scrubber/ScrubberTooltipInformation'
import customFunctionEditorStore from '../store/customFunctionEditorStore'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function ActiveToggleButton() {
  const { isActivated, toggleIsActivated, areAllTestsPassing } =
    customFunctionEditorStore()
  const { t } = useAppTranslation(
    'components/bootcamp/CustomFunctionEditor/Header'
  )

  return (
    <div>
      <ToggleButton
        className="w-fit"
        disabled={!areAllTestsPassing}
        checked={isActivated}
        onToggle={toggleIsActivated}
      />
      {!areAllTestsPassing && (
        <StaticTooltip
          text={t('activeToggleButton.activateFunctionOnlyWhenTestsPass')}
          className="block"
        />
      )}
    </div>
  )
}
