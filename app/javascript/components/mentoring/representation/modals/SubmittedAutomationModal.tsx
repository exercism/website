import React from 'react'
import { Modal } from '@/components/modals/Modal'
import { GraphicalIcon, Icon, Reputation } from '@/components/common'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export type AutomationModalProps = {
  isOpen: boolean
  onClose: () => void
}
export function SubmittedAutomationModal({
  isOpen,
  onClose,
  goBackLink,
}: AutomationModalProps & { goBackLink: string }): JSX.Element {
  const { t } = useAppTranslation()

  return (
    <Modal ReactModalClassName="!rounded-24" open={isOpen} onClose={onClose}>
      <div className="flex flex-col items-center rounded-24">
        <GraphicalIcon icon="green-check" className="w-[64px] h-[64px] mb-12" />
        <h2 className="text-h2 mb-12">
          {t('submittedAutomationModal.thanksForFeedback')}
        </h2>
        <p className="w-[640px] text-18 leading-paragraph text-center mb-20">
          {t('submittedAutomationModal.shownToStudents')}{' '}
          <strong className="font-medium">
            {t('submittedAutomationModal.solutionShownTimes')}
          </strong>
        </p>

        <a href={goBackLink} className="btn-m btn-primary">
          <div className="flex flex-row justify-center text-18">
            {t('submittedAutomationModal.continueToSolutions')}{' '}
            <Icon
              alt={t('submittedAutomationModal.right')}
              icon="arrow-right"
              className="w-[16px] h-[16px] filter-white ml-12"
            />
          </div>
        </a>
        <div className="flex mt-32 -mb-32 -mx-48 p-20 justify-center place-self-stretch bg-backgroundColorE border-borderColor6 border-t-1">
          <div className="flex flex-row items-center border-gradient-primary text-white font-medium text-16 border border-4 rounded-12  px-24 py-8 child:mx-6">
            {t('submittedAutomationModal.earnedReputation')}{' '}
            <Reputation value="+3" type="primary" size="small" />
            {t('submittedAutomationModal.reputationForFeedback')}
          </div>
        </div>
      </div>
    </Modal>
  )
}
