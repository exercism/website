import React, { useState } from 'react'
import { GraphicalIcon } from '@/components/common'
import CopyToClipboardButton from '@/components/common/CopyToClipboardButton'
import { Modal } from '../Modal'

type Links = {
  profile: string
}

export default function FirstTimeModal({
  links,
}: {
  links: Links
}): JSX.Element {
  const [open, setOpen] = useState(true)

  return (
    <Modal
      open={open}
      onClose={() => {
        setOpen(false)
      }}
      className="m-profile-first-time"
    >
      <header>
        <GraphicalIcon icon="confetti" category="graphics" />
        <h2>You now have a public profile!</h2>
        <p>
          <strong>Good job!</strong> You&apos;ll now see your published
          solutions, mentoring testimonials, contributions and badges on your
          public profile.
        </p>
      </header>
      <div className="copy-section">
        <h3>You can share your profile with others too!</h3>
        <CopyToClipboardButton textToCopy={links.profile} />
      </div>
    </Modal>
  )
}
