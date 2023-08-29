import React from 'react'
import { Modal } from '@/components/modals'
import { Submission } from '../types'
import { SingleSelect } from '@/components/common/SingleSelect'
import { ErrorBoundary, useErrorHandler } from '@/components/ErrorBoundary'

export type GptModelInfo = {
  version: GPTModel
  usage: number
}
export type GptUsage = {
  '3.5': number
  '4.0': number
}
type ChatGptDialogModalProps = {
  open: boolean
  onClose: () => void
  onGo: () => void
  submission: Submission
  value: GptModelInfo
  setValue: (v: GptModelInfo) => void
  chatgptUsage: GptUsage
  error: unknown
  exceededLimit: boolean
}

export type GPTModel = '3.5' | '4.0'

const OptionComponent = ({
  option: model,
}: {
  option: GptModelInfo
}): JSX.Element | null => {
  switch (model.version) {
    case '3.5':
      return (
        <React.Fragment>
          <div className="text-p-base flex items-center w-100">
            ChatGPT 3.5 - Less powerful but faster &amp; cheaper
            <span className="text-textColor6 font-semibold ml-auto text-14 flex items-center">
              {model.usage}/30
            </span>
          </div>
        </React.Fragment>
      )
    case '4.0':
      return (
        <React.Fragment>
          <div className="text-p-base flex items-center w-100">
            ChatGPT 4 - The latest, most powerful model
            <span className="text-textColor6 font-semibold ml-auto text-14 flex items-center">
              {model.usage}/3
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
  option: GptModelInfo
}): JSX.Element | null => {
  switch (model.version) {
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

const DEFAULT_ERROR = new Error('Unable to ask ChatGPT')
export const ChatGptDialog = ({
  open,
  onClose,
  onGo,
  value,
  setValue,
  chatgptUsage,
  error,
  exceededLimit,
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
      <h3 className="text-h5 mb-8">Are you sure you want to ask ChatGPT?</h3>
      <p className="text-p-base mb-16">
        ChatGPT is a powerful tool, but it can also make it too easy to get
        unstuck and remove a lot of the learning opportunity that comes from
        wrestling with a problem. We recommend only using it when you&apos;re
        too stuck to continue without help.
      </p>

      <div className="text-p-base text-textColor6 mb-8">Select a model:</div>
      <SingleSelect<GptModelInfo>
        options={gptUsageToArray(chatgptUsage)}
        OptionComponent={OptionComponent}
        SelectedComponent={SelectedComponent}
        value={value}
        setValue={setValue}
      />
      <div className="text-textColor6 text-p-small mt-12">
        Note: ChatGPT 4 is{' '}
        <strong className="font-medium">significantly</strong> better. However,
        ChatGPT 4 costs $0.20 per request (about 15x more than ChatGPT 3.5) so
        we have strict limits and give both options. Quotas reset on the first
        of each month. We suggest trying ChatGPT 3 first, then use one of your
        v4 tokens if needed.
      </div>

      {exceededLimit ? (
        <div className="c-alert--danger text-16 font-body mt-16 normal-case">
          You have exceeded the limit
        </div>
      ) : (
        <ErrorBoundary FallbackComponent={ErrorFallback}>
          <ErrorMessage error={error} />
        </ErrorBoundary>
      )}
      <div className="flex gap-8 mt-32 ">
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

const ErrorMessage = ({ error }: { error: unknown }) => {
  useErrorHandler(error, { defaultError: DEFAULT_ERROR })

  return null
}

const ErrorFallback = ({ error }: { error: Error }) => {
  return (
    <div className="c-alert--danger text-16 font-body mt-16 normal-case">
      {error.message}
    </div>
  )
}

function gptUsageToArray(gptUsage: GptUsage): GptModelInfo[] {
  return Object.entries(gptUsage).map(([version, usage]) => ({
    version: version as GPTModel,
    usage,
  }))
}
