import React, { useState } from 'react'
import { WalkthroughModal } from '../modals/WalkthroughModal'

export const WalkthroughButton = ({ html }: { html: string }): JSX.Element => {
  const [open, setOpen] = useState(false)

  return (
    <React.Fragment>
      <button type="button" onClick={() => setOpen(!open)}>
        View walkthrough
      </button>
      <WalkthroughModal
        open={open}
        onClose={() => setOpen(false)}
        className="m-walkthrough"
        html={html}
      />
    </React.Fragment>
  )
}
