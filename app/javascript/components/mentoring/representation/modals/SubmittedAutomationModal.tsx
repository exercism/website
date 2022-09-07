import React from 'react'
import { Modal } from '../../../../components/modals/Modal'
import { GraphicalIcon, Icon, Reputation } from '../../../common'
import { PrimaryButton } from '../common/PrimaryButton'

export type AutomationModalProps = {
  isOpen: boolean
  onClose: () => void
}
export function SubmittedAutomationModal({
  isOpen,
  onClose,
  goBackLink,
}: AutomationModalProps & { goBackLink: string }): JSX.Element {
  return (
    <Modal ReactModalClassName="!rounded-24" open={isOpen} onClose={onClose}>
      <div className="flex flex-col items-center rounded-24">
        <GraphicalIcon icon="green-check" className="w-[64px] h-[64px] mb-12" />
        <h2 className="text-h2 mb-12">Thanks for submitting feedback!</h2>
        <p className="w-[640px] text-18 leading-paragraph text-center mb-20">
          This will get shown to the relevant students on their solutions as
          they work through exercises.{' '}
          <strong className="font-medium">
            We’ll show you how many times your solution gets shown to students
            too.
          </strong>
        </p>
        <div className="flex flex-row items-center border-gradient-primary text-white font-medium text-18 border border-4 rounded-12  px-24 py-8 mb-32 child:mx-12">
          You earned <Reputation value="+3" type="primary" size="small" />{' '}
          Reputation for this, thanks 😊
        </div>

        <a href={goBackLink}>
          <PrimaryButton
            className="!w-[100%] py-[16px] px-[24px] mb-16"
            onClick={() => null}
          >
            <div className="flex flex-row justify-center text-18">
              Continue to solutions requiring feedback{' '}
              <Icon
                alt="right"
                icon="arrow-right"
                className="w-[16px] h-[16px] filter-white ml-12"
              />
            </div>
          </PrimaryButton>
        </a>
      </div>
    </Modal>
  )
}
