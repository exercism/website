import React from 'react'
import { Icon } from '../../common/Icon'
import { GenericTooltip } from '../../misc/ExercismTippy'

export const LinkButton = ({
  value,
  setValue,
}: {
  value: boolean
  setValue: (settings: boolean) => void
}): JSX.Element => {
  const classNames = ['settings-button', value ? 'linked' : 'unlinked']

  const content = value ? 'Linked' : 'Unlinked'

  return (
    <GenericTooltip content={content}>
      <button className={classNames.join(' ')} onClick={() => setValue(!value)}>
        <Icon icon="settings" alt="Link conversation" />
      </button>
    </GenericTooltip>
  )
}
