import React, { useCallback, useState } from 'react'
import { QueryStatus } from 'react-query'
import { MarkdownEditorForm } from '../../../common/MarkdownEditorForm'
import { MarkdownEditorForm } from './MarkdownEditorForm'
import { PanesProps } from '../left-pane/LeftPane'
import { PreviewAutomationModal } from '../modals/PreviewAutomationModal'
import { SubmittedAutomationModal } from '../modals/SubmittedAutomationModal'
import { PrimaryButton } from '../common/PrimaryButton'
import { CancelButton } from '../common/CancelButton'

export default function MentoringConversation({
  exerciseData,
  currentIteration,
  handleIterationClick,
  isLinked,
  setIsLinked,
  data,
}: PanesProps): JSX.Element {
  const [value, setValue] = useState(data.representation.feedbackMarkdown || '')
  const [isModalOpen, setIsModalOpen] = useState(false)
  const [isPreviewModalOpen, setIsPreviewModalOpen] = useState(false)

  const handleCancel = useCallback(() => console.log('Cancelled!'), [])
  const handleChange = useCallback((value) => setValue(value), [setValue])
  return (
    <div className="px-24">
      <MarkdownEditorForm
        value={value}
        onChange={handleChange}
        action="edit"
        onSubmit={() => setIsPreviewModalOpen(true)}
        onCancel={handleCancel}
        expanded
        defaultError={new Error('ERROR!')}
        error="Error"
        status={'success' as QueryStatus}
      />
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
        handleIterationClick={handleIterationClick}
        isLinked={isLinked}
        setIsLinked={setIsLinked}
      />
      <SubmittedAutomationModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
      />
    </div>
  )
}
