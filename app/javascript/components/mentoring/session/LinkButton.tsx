import React from 'react'
import { Icon } from '../../common/Icon'
import { GenericTooltip } from '../../misc/ExercismTippy'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const LinkButton = ({
  value,
  setValue,
}: {
  value: boolean
  setValue: (settings: boolean) => void
}): JSX.Element => {
  const { t } = useAppTranslation('session-batch-3')
  const classNames = ['link-button btn-enhanced', value ? 'linked' : 'unlinked']

  const content = value ? (
    <div className="c-mentoring-link-tooltip">
      <h3>{t('components.mentoring.session.linkButton.conversationLinked')}</h3>
      <p>
        {t(
          'components.mentoring.session.linkButton.conversationLinkedDescription'
        )}
        <strong>
          {t('components.mentoring.session.linkButton.clickToUnlink')}
        </strong>
      </p>
    </div>
  ) : (
    <div className="c-mentoring-link-tooltip">
      <h3>
        {t('components.mentoring.session.linkButton.conversationUnlinked')}
      </h3>
      <p>
        {t(
          'components.mentoring.session.linkButton.conversationUnlinkedDescription'
        )}
        <strong>
          {t('components.mentoring.session.linkButton.clickToLink')}
        </strong>
      </p>
    </div>
  )

  return (
    <GenericTooltip content={content}>
      <button className={classNames.join(' ')} onClick={() => setValue(!value)}>
        <Icon
          icon={value ? 'mentoring-linked' : 'mentoring-unlinked'}
          alt="Link conversation"
        />
      </button>
    </GenericTooltip>
  )
}
