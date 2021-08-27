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
  const classNames = ['link-button btn-enhanced', value ? 'linked' : 'unlinked']

  const content = value ? (
    <div className="c-mentoring-link-tooltip">
      <h3>Your code and mentoring conversation are currently linked.</h3>
      <p>
        This means as you navigate to another iteration, the mentoring
        conversation will follow and vice versa.
        <strong>Click or tap on the icon to unlink.</strong>
      </p>
    </div>
  ) : (
    <div className="c-mentoring-link-tooltip">
      <h3>Your code and mentoring conversation are currently unlinked.</h3>
      <p>
        This means the left and right panes operate independently.
        <strong>Click or tap on the icon to link.</strong>
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
