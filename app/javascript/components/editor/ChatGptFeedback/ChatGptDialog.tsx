// i18n-key-prefix: chatGptDialog
// i18n-namespace: components/editor/ChatGptFeedback
import React from 'react'
import { Modal } from '@/components/modals'
import { Submission } from '../types'
import { SingleSelect } from '@/components/common/SingleSelect'
import { ErrorBoundary, useErrorHandler } from '@/components/ErrorBoundary'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

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
  const { t } = useAppTranslation('components/editor/ChatGptFeedback')

  return (
    <Modal
      open={open}
      closeButton={false}
      onClose={onClose}
      shouldCloseOnEsc={false}
      shouldCloseOnOverlayClick
      ReactModalClassName={`max-w-[40%]`}
    >
      <h3 className="text-h5 mb-8">
        {t('chatGptDialog.areYouSureYouWantToAskChatGPT')}
      </h3>
      <p className="text-p-base mb-16">
        {t('chatGptDialog.chatGptIsAPowerfulTool')}
      </p>

      <div className="text-p-base text-textColor6 mb-8">
        {t('chatGptDialog.selectAModel')}
      </div>
      <SingleSelect<GptModelInfo>
        options={gptUsageToArray(chatgptUsage)}
        OptionComponent={OptionComponent}
        SelectedComponent={SelectedComponent}
        value={value}
        setValue={setValue}
      />
      <div className="text-textColor6 text-p-small mt-12">
        <Trans
          i18nKey="chatGptDialog.noteChatGPT4IsSignificantlyBetter"
          ns="components/editor/ChatGptFeedback"
          components={{
            bold: <strong className="font-semibold" />,
          }}
        />
      </div>

      {exceededLimit ? (
        <div className="c-alert--danger text-16 font-body mt-16 normal-case">
          {t('chatGptDialog.youHaveExceededTheLimit')}
        </div>
      ) : (
        <ErrorBoundary FallbackComponent={ErrorFallback}>
          <ErrorMessage error={error} />
        </ErrorBoundary>
      )}
      <div className="flex gap-8 mt-32 ">
        <button className="btn-s btn-primary" onClick={onGo}>
          {t('chatGptDialog.go')}
        </button>
        <button className="btn-s btn-default" onClick={onClose}>
          {t('chatGptDialog.cancel')}
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
