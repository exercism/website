import React from 'react'
import { ActionIcon } from '../../contributing/tasks-list/task/ActionIcon'
import { TaskAction } from '../../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

export const ActionInfo = ({ action }: { action: TaskAction }): JSX.Element => {
  return (
    <section>
      <div className="icon">
        <ActionIcon action={action} />
      </div>
      <div className="details">
        <ActionDetails action={action} />
      </div>
    </section>
  )
}

const ActionDetails = ({ action }: { action: TaskAction }): JSX.Element => {
  const { t } = useAppTranslation('components/tooltips/task-tooltip')

  const transComponents = { strong: <strong /> }
  const transNs = 'components/tooltips/task-tooltip'

  switch (action) {
    case 'create':
      return (
        <>
          <h3>
            <Trans
              ns={transNs}
              i18nKey="actionInfo.createNew"
              components={transComponents}
            />
          </h3>
          <p>{t('actionInfo.buildingFromScratch')}</p>
        </>
      )
    case 'fix':
      return (
        <>
          <h3>
            <Trans
              ns={transNs}
              i18nKey="actionInfo.fixBroken"
              components={transComponents}
            />
          </h3>
          <p>{t('actionInfo.fixingIt')}</p>
        </>
      )
    case 'improve':
      return (
        <>
          <h3>
            <Trans
              ns={transNs}
              i18nKey="actionInfo.improveSomething"
              components={transComponents}
            />
          </h3>
          <p>{t('actionInfo.addFeatureOrImprovement')}</p>
        </>
      )
    case 'proofread':
      return (
        <>
          <h3>
            <Trans
              ns={transNs}
              i18nKey="actionInfo.proofread"
              components={transComponents}
            />
          </h3>
          <p>{t('actionInfo.checkDocsAndContent')}</p>
        </>
      )
    case 'sync':
      return (
        <>
          <h3>
            <Trans
              ns={transNs}
              i18nKey="actionInfo.syncContent"
              components={transComponents}
            />
          </h3>
          <p>{t('actionInfo.updateTrackImplementation')}</p>
        </>
      )
  }
}
