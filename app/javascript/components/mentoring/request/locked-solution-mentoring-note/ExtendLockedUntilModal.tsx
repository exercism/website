import React from 'react'
import { Modal } from '@/components/modals'
import { GraphicalIcon } from '@/components/common'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function ExtendLockedUntilModal({
  open,
  onClose,
  onExtend,
  diffMinutes,
  adjustOpenModalAt,
}: {
  open: boolean
  onClose: () => void
  onExtend: () => void
  diffMinutes: string
  adjustOpenModalAt: () => void
}): JSX.Element {
  const { t } = useAppTranslation(
    'components/mentoring/request/locked-solution-mentoring-note'
  )

  return (
    <Modal
      onClose={onClose}
      style={{ content: { width: '740px' } }}
      open={open}
      shouldCloseOnEsc={false}
      shouldCloseOnOverlayClick={false}
      aria={{
        modal: true,
        labelledby: 'extend-mentoring-request-lock-label',
        describedby: 'extend-mentoring-request-lock-description',
      }}
    >
      <div className="flex items-start">
        <div className="flex flex-col mr-32">
          <h3 id="extend-mentoring-request-lock-label" className="text-h3 mb-6">
            {t('extendLockedUntilModal.mentorLockExpiring')}
          </h3>
          <p
            className="text-p-large mb-8"
            id="extend-mentoring-request-lock-description"
          >
            {t('extendLockedUntilModal.timeRemaining', { diffMinutes })}
          </p>
          <p className="text-p-large mb-20">
            {t('extendLockedUntilModal.wouldLikeMoreTime')}
          </p>
          <div className="flex gap-16">
            <button onClick={onExtend} className="btn-m btn-primary">
              {t('extendLockedUntilModal.yesExtend')}
            </button>
            <button
              className="btn-m btn-secondary"
              onClick={() => {
                onClose()
                adjustOpenModalAt()
              }}
            >
              {t('extendLockedUntilModal.noThankYou')}
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
