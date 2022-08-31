import React, { useState } from 'react'
import { SplitPane } from '../../../common'
import { Modal } from '../../../modals/Modal'
import { IterationView } from '../left-pane/RepresentationIterationView'
import { PreviewFeedbackComment } from './PreviewFeedbackComment'
import { PreviewFooter } from './PreviewFooter'
import { AutomationModalProps } from './SubmittedAutomationModal'
import { CompleteRepresentationData } from '../../../types'

type PreviewAutomationModalProps = AutomationModalProps & {
  data: CompleteRepresentationData
  markdown: string
}

export function PreviewAutomationModal({
  data,
  onClose,
  isOpen,
  markdown,
}: PreviewAutomationModalProps): JSX.Element {
  const [selectedExample, setSelectedExample] = useState<number>(0)

  return (
    <Modal
      ReactModalClassName="c-mentor-discussion !p-0 !w-[80%] flex flex-col"
      onClose={onClose}
      open={isOpen}
    >
      <SplitPane
        id="automation-preview"
        left={
          <IterationView
            representationData={{
              ...data.representation,
              ...data.examples[selectedExample],
            }}
          />
        }
        right={
          <PreviewFeedbackComment mentor={data.mentor} markdown={markdown} />
        }
        rightMinWidth={400}
      />
      <PreviewFooter
        examples={data.examples}
        selectedExample={selectedExample}
        setSelectedExample={setSelectedExample}
        numOfSolutions={2170}
        onClose={onClose}
      />
    </Modal>
  )
}
