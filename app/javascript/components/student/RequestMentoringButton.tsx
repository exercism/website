import React, { useState } from 'react'
import { RequestMentoringModal } from '../modals/RequestMentoringModal'
import { Request } from '../../hooks/request-query'

export type Links = {
  mentorRequest: string
}

export default function RequestMentoringButton({
  request,
  links,
}: {
  request: Request
  links: Links
}): JSX.Element {
  const [open, setOpen] = useState(false)

  return (
    <React.Fragment>
      <button
        type="button"
        onClick={() => setOpen(true)}
        className="available-slot"
      >
        <h4>Mentoring slot available</h4>
        <div className="btn-simple">Select an exercise</div>
      </button>
      <RequestMentoringModal
        open={open}
        onClose={() => setOpen(false)}
        request={request}
        links={links}
      />
    </React.Fragment>
  )
}
