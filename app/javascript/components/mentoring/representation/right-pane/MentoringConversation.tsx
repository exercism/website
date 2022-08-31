import React, { useCallback, useState } from 'react'
import { PanesProps } from '../left-pane/LeftPane'
import { PreviewAutomationModal } from '../modals/PreviewAutomationModal'
import { SubmittedAutomationModal } from '../modals/SubmittedAutomationModal'
import { PrimaryButton } from '../common/PrimaryButton'
import { CancelButton } from '../common/CancelButton'
import { MarkdownEditor } from '../../../common/MarkdownEditor'

export default function MentoringConversation({
  exerciseData,
  currentIteration,
  data,
}: PanesProps): JSX.Element {
  const [value, setValue] = useState(data.representation.feedbackMarkdown || '')
  const [isModalOpen, setIsModalOpen] = useState(false)
  const [isPreviewModalOpen, setIsPreviewModalOpen] = useState(false)

  // something to do here
  // const handleCancel = useCallback(() => console.log('Cancelled!'), [])
  const handleChange = useCallback((value) => setValue(value), [setValue])
  return (
    <div className="px-24">
      <div id="markdown-editor" className="c-markdown-editor --expanded">
        <MarkdownEditor onChange={handleChange} value={value} />
      </div>
      <div className="mt-12 mb-20 text-textColor6 bg-veryLightBlue py-4 px-8 rounded-5">
        We imported your last mentoring feedback to this solution above
      </div>

      <div>
        <PrimaryButton
          className="px-[64px] py-[12px] mb-16 mr-24"
          onClick={() => setIsPreviewModalOpen(true)}
        >
          Preview & Submit
        </PrimaryButton>
        <CancelButton />
      </div>
      <div className="text-textColor6 ">
        Remember, you can edit this feedback anytime after submission.
      </div>
      <PreviewAutomationModal
        data={data}
        isOpen={isPreviewModalOpen}
        markdown={value}
        onClose={() => setIsPreviewModalOpen(false)}
        currentIteration={currentIteration}
        exerciseData={exerciseData}
      />
      <SubmittedAutomationModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
      />
    </div>
  )
}
