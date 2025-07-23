// i18n-key-prefix: disabledTooltip
// i18n-namespace: components/settings/theme-preference-form
import { GraphicalIcon } from '@/components/common'
import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'
export function DisabledTooltip(): JSX.Element {
  const { t } = useAppTranslation('components/settings/theme-preference-form')
  return (
    <div className="flex items-center bg-russianViolet rounded-16 py-8 px-12 text-p-base text-aliceBlue">
      <Trans
        i18nKey="disabledTooltip.mustBeExercismInsider"
        ns="components/settings/theme-preference-form"
        components={{
          0: (
            <strong
              style={{ color: 'inherit' }}
              className="flex items-center"
            />
          ),
          1: <GraphicalIcon icon="insiders" height={24} width={24} />,
        }}
      />
    </div>
  )
}
