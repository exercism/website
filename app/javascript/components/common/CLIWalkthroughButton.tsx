import React, { useState } from 'react'
import { CLIWalkthroughModal } from '../modals/CLIWalkthroughModal'
import { GraphicalIcon, Icon } from '../common'

export default ({ html }: { html: string }): JSX.Element => {
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
          <div className="--title">Install Exercism locally</div>
          <div className="--explanation">
            Use our wizard to setup Exercism to work on your local machine.
          </div>
        </div>
        <Icon icon="modal" alt="Opens in a modal" className="modal-icon" />
      </button>
      <CLIWalkthroughModal
        open={open}
        onClose={() => setOpen(false)}
        html={html}
      />
    </React.Fragment>
  )
}
