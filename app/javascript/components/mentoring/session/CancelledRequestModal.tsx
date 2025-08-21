import { Modal } from '@/components/modals'
import React from 'react'
import { Links } from '../Session'
import { GraphicalIcon } from '@/components/common'
import { useAppTranslation } from '@/i18n/useAppTranslation'

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
  const { t } = useAppTranslation('session-batch-1')
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
            {t(
              'components.mentoring.session.cancelledRequestModal.mentoringRequestCancelled'
            )}
          </h3>
          <p
            id="cancelled-mentoring-request-description"
            className="text-p-large mb-8"
          >
            {t(
              'components.mentoring.session.cancelledRequestModal.studentCancelledRequest'
            )}
          </p>
          <p className="text-p-large mb-16">
            {t(
              'components.mentoring.session.cancelledRequestModal.thankYouForBeingAMentor'
            )}
          </p>
          <div className="flex gap-16">
            <a href={links.mentorQueue} className="btn-m btn-primary">
              {t(
                'components.mentoring.session.cancelledRequestModal.backToMentorRequests'
              )}
            </a>
            {isLocked && (
              <button className="btn-m btn-secondary" onClick={onClose}>
                {t(
                  'components.mentoring.session.cancelledRequestModal.closeThisModal'
                )}
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
