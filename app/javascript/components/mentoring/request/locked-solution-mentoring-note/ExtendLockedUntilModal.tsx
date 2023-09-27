import React from 'react'
import { Modal } from '@/components/modals'
import { GraphicalIcon } from '@/components/common'

export function ExtendLockedUntilModal({
  open,
  onClose,
  onExtend,
}: {
  open: boolean
  onClose: () => void
  onExtend: () => void
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
      <div className="flex items-start">
        <div className="flex flex-col mr-32">
          <h3
            id="cancelled-mentoring-request-description"
            className="text-h3 mb-6"
          >
            Mentor Lock close to expiring
          </h3>
          <p className="text-p-large mb-8">
            You only have 10 minutes remaining to submit your comment before
            this mentor request is unlocked for other mentors to reply to.
          </p>
          <p className="text-p-large mb-20">Would you like more time?</p>
          <div className="flex gap-16">
            <button onClick={onExtend} className="btn-m btn-primary">
              Yes, extend for 30 minutes
            </button>
            <button className="btn-m btn-secondary" onClick={onClose}>
              No, thank you
            </button>
          </div>
        </div>
        <GraphicalIcon
          icon="alarm-alert"
          category="graphics"
          className="ml-auto"
          height={128}
          width={128}
        />
      </div>
    </Modal>
  )
}
