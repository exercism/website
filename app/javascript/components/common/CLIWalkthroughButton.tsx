import React, { useState } from 'react'
import { CLIWalkthroughModal } from '../modals/CLIWalkthroughModal'

export const CLIWalkthroughButton = ({
  html,
}: {
  html: string
}): JSX.Element => {
  const [open, setOpen] = useState(false)

  return (
    <React.Fragment>
      <button type="button" onClick={() => setOpen(!open)}>
        View walkthrough
      </button>
      <CLIWalkthroughModal
        open={open}
        onClose={() => setOpen(false)}
        html={html}
      />
    </React.Fragment>
  )
}
