// i18n-key-prefix: reputationInfo
// i18n-namespace: components/modals/mentor-registration-modal/commit-step
import React from 'react'
import { GraphicalIcon } from '../../../common'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

export const ReputationInfo = (): JSX.Element => {
  const { t } = useAppTranslation(
    'components/modals/mentor-registration-modal/commit-step'
  )
  return (
    <div className="reputation-info">
      <div className="inner">
        <GraphicalIcon icon="reputation" />
        <div className="info">
          <h3>{t('reputationInfo.reputationAndTestimonials')}</h3>
          <p>
            {
              <Trans
                i18nKey="reputationInfo.gainReputation"
                ns="components/modals/mentor-registration-modal/commit-step"
                components={[<strong />]}
              />
            }
          </p>
        </div>
      </div>
    </div>
  )
}
