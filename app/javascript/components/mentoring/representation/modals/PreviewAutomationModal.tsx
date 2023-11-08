import React, { useCallback, useState } from 'react'
import { useMutation } from '@tanstack/react-query'
import {
  CompleteRepresentationData,
  RepresentationFeedbackType,
} from '@/components/types'
import { SplitPane } from '@/components/common/SplitPane'
import { Modal } from '@/components/modals'
import { sendRequest } from '@/utils/send-request'
import { IterationView } from '../left-pane/RepresentationIterationView'
import { PreviewFeedbackComment } from './PreviewFeedbackComment'
import { PreviewFooter } from './PreviewFooter'
import { AutomationModalProps } from './SubmittedAutomationModal'

type PreviewAutomationModalProps = AutomationModalProps & {
  data: CompleteRepresentationData
  html: string
  markdown: string
  feedbackType: RepresentationFeedbackType
  onSuccessfulSubmit: () => void
}

export function PreviewAutomationModal({
  data,
  onClose,
  isOpen,
  html,
  markdown,
  feedbackType,
  onSuccessfulSubmit,
}: PreviewAutomationModalProps): JSX.Element {
  const [selectedExample, setSelectedExample] = useState<number>(0)

  async function SubmitFeedback() {
    const { fetch } = sendRequest<{ html: string }>({
      endpoint: data.representation.links.update!,
      method: 'PATCH',
      body: JSON.stringify({
        representation: {
          feedback_type: feedbackType,
          feedback_markdown: markdown,
        },
      }),
    })
    return fetch
  }

  const { mutate: submitFeedback } = useMutation(SubmitFeedback, {
    onSuccess: onSuccessfulSubmit,
  })

  const handleSubmit = useCallback(() => {
    submitFeedback()
  }, [submitFeedback])

  return (
    <Modal
      ReactModalClassName="c-mentor-discussion !p-0 !w-[80%] !h-[65vh] flex flex-col"
      onClose={onClose}
      open={isOpen}
    >
      <SplitPane
        id="automation-preview"
        rightMinWidth={350}
        leftMinWidth={550}
        defaultLeftWidth="100%"
        left={
          <IterationView
            representationData={{
              ...data.representation,
              ...data.examples[selectedExample],
            }}
          />
        }
        right={
          <PreviewFeedbackComment
            feedbackType={feedbackType}
            mentor={data.mentor}
            html={html}
          />
        }
      />
      <PreviewFooter
        onSubmit={handleSubmit}
        examples={data.examples}
        selectedExample={selectedExample}
        setSelectedExample={setSelectedExample}
        numOfSolutions={data.representation.numSubmissions}
        onClose={onClose}
      />
    </Modal>
  )
}
