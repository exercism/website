import React from 'react'
import { Modal } from '@/components/modals'
import { Submission } from '../types'
import { SingleSelect } from '@/components/common'

type ChatGptDialogModalProps = {
  open: boolean
  onClose: () => void
  onGo: () => void
  submission: Submission
  value: GPTModel
  setValue: (v: GPTModel) => void
}

export type GPTModel = '3.5' | '4.0'

const OptionComponent = ({
  option: model,
}: {
  option: GPTModel
}): JSX.Element | null => {
  switch (model) {
    case '3.5':
      return (
        <React.Fragment>
          <div className="text-p-base flex items-center w-100">
            ChatGPT 3.5{' '}
            <span className="text-textColor6 font-semibold ml-auto text-14 flex items-center">
              0/100
            </span>
          </div>
        </React.Fragment>
      )
    case '4.0':
      return (
        <React.Fragment>
          <div className="text-p-base flex items-center w-100">
            ChatGPT 4{' '}
            <span className="text-textColor6 font-semibold ml-auto text-14 flex items-center">
              0/10
            </span>
          </div>
        </React.Fragment>
      )
    default:
      return null
  }
}

const SelectedComponent = ({
  option: model,
}: {
  option: GPTModel
}): JSX.Element | null => {
  switch (model) {
    case '3.5':
      return (
        <React.Fragment>
          <div className="text-p-base flex items-center w-100">GPT-3.5 </div>
        </React.Fragment>
      )
    case '4.0':
      return (
        <React.Fragment>
          <div className="text-p-base flex items-center w-100">GPT-4 </div>
        </React.Fragment>
      )
    default:
      return null
  }
}

export const ChatGptDialog = ({
  open,
  onClose,
  onGo,
  value,
  setValue,
  chatgptUsage,
}: ChatGptDialogModalProps): JSX.Element => {
  return (
    <Modal
      open={open}
      closeButton={false}
      onClose={onClose}
      shouldCloseOnEsc={false}
      shouldCloseOnOverlayClick
      ReactModalClassName={`max-w-[40%]`}
    >
      <div className="text-h5 mb-16">Are you sure you want to ask ChatGPT?</div>

      <div className="text-textColor6 mt-32">Select a model:</div>
      <SingleSelect<GPTModel>
        componentClassName="mb-32 mt-8"
        options={['3.5', '4.0']}
        OptionComponent={OptionComponent}
        SelectedComponent={SelectedComponent}
        value={value}
        setValue={setValue}
      />
      <div className="flex gap-8">
        <button className="btn-s btn-primary" onClick={onGo}>
          Go
        </button>
        <button className="btn-s btn-default" onClick={onClose}>
          Cancel
        </button>
      </div>
    </Modal>
  )
}
