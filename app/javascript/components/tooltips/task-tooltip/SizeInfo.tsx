import React from 'react'
import { SizeTag } from '../../contributing/tasks-list/task/SizeTag'
import { TaskSize } from '../../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

export const SizeInfo = ({ size }: { size: TaskSize }): JSX.Element => {
  return (
    <section>
      <div className="icon">
        <SizeTag size={size} />
      </div>
      <div className="details">
        <SizeDetails size={size} />
      </div>
    </section>
  )
}

const SizeDetails = ({ size }: { size: TaskSize }): JSX.Element => {
  const { t } = useAppTranslation('components/tooltips/task-tooltip')

  const transComponents = { strong: <strong /> }
  const transNs = 'components/tooltips/task-tooltip'

  switch (size) {
    case 'tiny':
      return (
        <>
          <h3>
            <Trans
              ns={transNs}
              i18nKey="sizeInfo.tinyTask"
              components={transComponents}
            />
          </h3>
          <p>{t('sizeInfo.completeInMinutes')}</p>
        </>
      )
    case 'small':
      return (
        <>
          <h3>
            <Trans
              ns={transNs}
              i18nKey="sizeInfo.smallTask"
              components={transComponents}
            />
          </h3>
          <p>{t('sizeInfo.completeInHour')}</p>
        </>
      )
    case 'medium':
      return (
        <>
          <h3>
            <Trans
              ns={transNs}
              i18nKey="sizeInfo.mediumSizedTask"
              components={transComponents}
            />
          </h3>
          <p>{t('sizeInfo.deepenKnowledge')}</p>
        </>
      )
    case 'large':
      return (
        <>
          <h3>
            <Trans
              ns={transNs}
              i18nKey="sizeInfo.largeTask"
              components={transComponents}
            />
          </h3>
          <p>{t('sizeInfo.bigContribution')}</p>
        </>
      )
    case 'massive':
      return (
        <>
          <h3>
            <Trans
              ns={transNs}
              i18nKey="sizeInfo.project"
              components={transComponents}
            />
          </h3>
          <p>{t('sizeInfo.daysToComplete')}</p>
        </>
      )
  }
}
