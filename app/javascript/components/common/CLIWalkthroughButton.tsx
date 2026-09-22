// i18n-namespace: components/common/CLIWalkthroughButton.tsx
import React, { useState } from 'react'
import { CLIWalkthroughModal } from '../modals/CLIWalkthroughModal'
import { GraphicalIcon, Icon } from '../common'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export default ({ html }: { html: string }): JSX.Element => {
  const { t } = useAppTranslation('components/common/CLIWalkthroughButton.tsx')
  const [open, setOpen] = useState(false)

  return (
    <React.Fragment>
      <button
        type="button"
        onClick={() => setOpen(!open)}
        className="c-cli-walkthrough-button"
      >
        <GraphicalIcon
          icon="wizard-prompt"
          category="graphics"
          className="graphical-icon"
        />
        <div className="info">
          <div className="--title">
            {t('cliWalkthroughButton.installExercismLocally')}
          </div>
          <div className="--explanation">
            {t('cliWalkthroughButton.useOurWizard')}
          </div>
        </div>
        <Icon
          icon="modal"
          alt={t('cliWalkthroughButton.opensInModal')}
          className="modal-icon"
        />
      </button>
      <CLIWalkthroughModal
        open={open}
        onClose={() => setOpen(false)}
        html={html}
      />
    </React.Fragment>
  )
}
