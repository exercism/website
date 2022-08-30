import React, { useCallback, useState } from 'react'
import { QueryStatus } from 'react-query'
import { MarkdownEditorForm } from '../../../common/MarkdownEditorForm'
import { PanesProps } from '../left-pane/LeftPane'
import { PreviewAutomationModal } from '../modals/PreviewAutomationModal'
import { SubmittedAutomationModal } from '../modals/SubmittedAutomationModal'

export default function MentoringConversation({
  exerciseData,
  currentIteration,
  handleIterationClick,
  isLinked,
  setIsLinked,
}: PanesProps): JSX.Element {
  const [value, setValue] = useState('')
  const [isModalOpen, setIsModalOpen] = useState(false)
  const [isPreviewModalOpen, setIsPreviewModalOpen] = useState(false)

  const handleCancel = useCallback(() => console.log('Cancelled!'), [])
  const handleChange = useCallback((value) => setValue(value), [setValue])
  return (
    <div className="px-24">
      <MarkdownEditorForm
        value={value}
        onChange={handleChange}
        onCancel={handleCancel}
        expanded
        action="edit"
        defaultError={new Error('ERROR!')}
        error="Error"
        onSubmit={() => setIsPreviewModalOpen(true)}
        status={'success' as QueryStatus}
      />
      <div className="mt-12 mb-20 text-textColor6 bg-veryLightBlue py-4 px-8 rounded-5">
        We imported your last mentoring feedback to this solution above
      </div>
      <PrimaryButton
        className="px-[18px] py-[12px] mb-16"
        onClick={() => setIsModalOpen(true)}
      >
        Preview & Submit
      </PrimaryButton>
      <div className="text-textColor6 ">
        Remember, you can edit this feedback anytime after submission.
      </div>
      <PreviewAutomationModal
        isOpen={isPreviewModalOpen}
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

export function PrimaryButton({
  onClick,
  children,
  className,
}: {
  onClick: () => void
  children: React.ReactChild
  className?: string
}): JSX.Element {
  return (
    // there could be an alias/class for this
    <button
      onClick={onClick}
      className={`border-1 border-primaryBtnBorder shadow-xsZ1v3 bg-purple text-white text-16 font-semibold rounded-8 ${className}`}
    >
      {children}
    </button>
  )
}
