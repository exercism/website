import React from 'react'
import { Modal } from '@/components/modals'
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
      <h3
        id="cancelled-mentoring-request-description"
        className="text-h3 mb-16 text-center"
      >
        You only have 10 minutes left to submit your comment. Would you like
        more time?
      </h3>
      <div className="flex justify-center gap-16">
        <button onClick={onExtend} className="btn-m btn-primary">
          Yes, extend for 30 minutes
        </button>
        <button className="btn-m btn-secondary" onClick={onClose}>
          No, thank you
        </button>
      </div>
    </Modal>
  )
}
