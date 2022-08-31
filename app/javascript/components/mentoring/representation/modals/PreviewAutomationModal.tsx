import React from 'react'
import { SplitPane } from '../../../common'
import { Modal } from '../../../modals/Modal'
import { IterationView } from '../left-pane/IterationView'
import { PanesProps } from '../left-pane/LeftPane'
import {
  PreviewFeedbackComment,
  PreviewFeedbackCommentProps,
} from './PreviewFeedbackComment'
import { PreviewFooter } from './PreviewFooter'
import { AutomationModalProps } from './SubmittedAutomationModal'

type PreviewAutomationModalProps = AutomationModalProps &
  PanesProps &
  Omit<PreviewFeedbackCommentProps, 'mentor'>

export function PreviewAutomationModal({
  data,
  onClose,
  isOpen,
  exerciseData,
  currentIteration,
  markdown,
}: PreviewAutomationModalProps): JSX.Element {
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
            testData={data}
            currentIteration={currentIteration}
            isOutOfDate={exerciseData.outOfDate}
            downloadCommand={exerciseData.downloadCommand}
          />
        }
        right={
          <PreviewFeedbackComment mentor={data.mentor} markdown={markdown} />
        }
        rightMinWidth={400}
      />
      <PreviewFooter examples={data.examples} numOfSolutions={2170} />
    </Modal>
  )
}
