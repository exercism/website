import React, { useState } from 'react'
import { Icon } from '../common'
import { ExerciseUpdateModal } from '../modals/ExerciseUpdateModal'

type Links = {
  diff: string
}

export default function UpdateExerciseNotice({
  links,
}: {
  links: Links
}): JSX.Element {
  const [open, setOpen] = useState(false)
  return (
    <React.Fragment>
      <button
        type="button"
        className="update-bar"
        onClick={() => setOpen(!open)}
      >
        <Icon icon="warning" alt="Warning" />
        This exercise has been updated. Update to the latest version and see if
        your tests still pass.
        <div className="faux-link">See what&apos;s changed…</div>
      </button>
      <ExerciseUpdateModal
        endpoint={links.diff}
        open={open}
        onClose={() => setOpen(false)}
      />
    </React.Fragment>
  )
}
