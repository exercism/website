// i18n-key-prefix: reputationInfo
// i18n-namespace: components/modals/mentor-registration-modal/commit-step
import React from 'react'
import { GraphicalIcon } from '../../../common'
import { useAppTranslation } from '@/i18n/useAppTranslation'

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
          <p>{t('reputationInfo.gainReputation')}</p>
        </div>
      </div>
    </div>
  )
}
