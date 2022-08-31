import React, { useCallback, useState } from 'react'
import { PreviewAutomationModal } from '../modals/PreviewAutomationModal'
import { SubmittedAutomationModal } from '../modals/SubmittedAutomationModal'
import { PrimaryButton } from '../common/PrimaryButton'
import { MarkdownEditor } from '../../../common/MarkdownEditor'
import { CompleteRepresentationData } from '../../../types'

export default function MentoringConversation({
  data,
}: {
  data: CompleteRepresentationData
}): JSX.Element {
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
      </div>
      <div className="text-textColor6 ">
        Remember, you can edit this feedback anytime after submission.
      </div>
      <PreviewAutomationModal
        data={data}
        isOpen={isPreviewModalOpen}
        markdown={value}
        onClose={() => setIsPreviewModalOpen(false)}
      />
      <SubmittedAutomationModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
      />
    </div>
  )
}
