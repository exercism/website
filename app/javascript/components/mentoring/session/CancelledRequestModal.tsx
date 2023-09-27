import { Modal } from '@/components/modals'
import React from 'react'
import { Links } from '../Session'
import { GraphicalIcon } from '@/components/common'

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
        labelledby: 'cancelled-mentoring-request-label',
      }}
    >
      <div className="flex items-start">
        <div className="flex flex-col mr-32">
          <h3 id="cancelled-mentoring-request-label" className="text-h3 mb-6">
            Mentoring request cancelled
          </h3>
          <p
            id="cancelled-mentoring-request-description"
            className="text-p-large mb-8"
          >
            The student has cancelled this mentoring request. We know this is
            extremely frustrating once you&apos;ve started responding 😞 Sorry
            for the annoyance!
          </p>
          <p className="text-p-large mb-16">
            Thank you for being a mentor at Exercism 💙
          </p>
          <div className="flex gap-16">
            <a href={links.mentorQueue} className="btn-m btn-primary">
              Back to mentor requests
            </a>
            {isLocked && (
              <button className="btn-m btn-secondary" onClick={onClose}>
                Close this modal
              </button>
            )}
          </div>
        </div>
        <GraphicalIcon
          icon="cancelled"
          category="graphics"
          className="ml-auto"
          height={128}
          width={128}
        />
      </div>
    </Modal>
  )
}
