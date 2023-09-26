import { Modal } from '@/components/modals'
import React from 'react'
import { Links } from '../Session'

export function CancelledRequestModal({
  open,
  onClose,
  links,
  isLocked,
}: {
  open: boolean
  onClose: () => void
  links: Links
  isLocked: boolean
}): JSX.Element {
  return (
    <Modal
      onClose={onClose}
      style={{ content: { width: '740px' } }}
      open={open}
      shouldCloseOnEsc={false}
      shouldCloseOnOverlayClick={false}
      aria={{
        modal: true,
        describedby: 'cancelled-mentoring-request-description',
      }}
    >
      <h3
        id="cancelled-mentoring-request-description"
        className="text-h3 mb-16 text-center"
      >
        The student has cancelled this mentoring request. <br />
        Sorry for the inconvenience!
      </h3>
      <div className="flex justify-center gap-16">
        <a href={links.mentorQueue} className="btn-m btn-primary">
          Back to mentor requests
        </a>
        {isLocked && (
          <button className="btn-m btn-secondary" onClick={onClose}>
            Close this modal
          </button>
        )}
      </div>
    </Modal>
  )
}
