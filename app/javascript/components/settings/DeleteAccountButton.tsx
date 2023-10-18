import React, { useState } from 'react'
import { DeleteAccountModal } from '../modals/DeleteAccountModal'

type Links = {
  delete: string
}

export default function DeleteAccountButton({
  handle,
  links,
}: {
  handle: string
  links: Links
}): JSX.Element {
  const [open, setOpen] = useState(false)

  return (
    <React.Fragment>
      <button
        type="button"
        className="c-delete-account-button btn-alert btn-m"
        onClick={() => setOpen(!open)}
      >
        Delete account
      </button>
      <DeleteAccountModal
        open={open}
        onClose={() => setOpen(false)}
        handle={handle}
        endpoint={links.delete}
      />
    </React.Fragment>
  )
}
