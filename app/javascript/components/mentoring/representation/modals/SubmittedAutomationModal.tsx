import React from 'react'
import { Modal } from '@/components/modals/Modal'
import { GraphicalIcon, Icon, Reputation } from '@/components/common'

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
            We&apos;ll show you how many times your solution gets shown to
            students too.
          </strong>
        </p>

        <a href={goBackLink} className="btn-m btn-primary">
          <div className="flex flex-row justify-center text-18">
            Continue to solutions requiring feedback{' '}
            <Icon
              alt="right"
              icon="arrow-right"
              className="w-[16px] h-[16px] filter-white ml-12"
            />
          </div>
        </a>
        <div className="flex mt-32 -mb-32 -mx-48 p-20 justify-center place-self-stretch bg-backgroundColorE border-borderColor6 border-t-1">
          <div className="flex flex-row items-center border-gradient-primary text-white font-medium text-16 border border-4 rounded-12  px-24 py-8 child:mx-6">
            You earned <Reputation value="+3" type="primary" size="small" />
            Reputation for providing this feedback 😊
          </div>
        </div>
      </div>
    </Modal>
  )
}
