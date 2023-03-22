import React, { useEffect } from 'react'
import { SubmitButton } from '../editor/SubmitButton'
import { Modal } from './Modal'
import { useQueryCache } from 'react-query'
import { SolutionChannel } from '@/channels/solutionChannel'

type Solution = {
  uuid: string
}

type RealtimeFeedbackModalProps = {
  open: boolean
  onClose: () => void
  onSubmit: () => void
  solution: Solution
}

export const RealtimeFeedbackModal = ({
  open,
  onClose,
  onSubmit,
  solution,
}: RealtimeFeedbackModalProps): JSX.Element => {
  const queryCache = useQueryCache()
  const CACHE_KEY = `editor-${solution.uuid}-feedback`
  useEffect(() => {
    const solutionChannel = new SolutionChannel(
      { uuid: solution.uuid },
      (response) => {
        queryCache.setQueryData(CACHE_KEY, response)
      }
    )

    return () => {
      solutionChannel.disconnect()
    }
  }, [CACHE_KEY, solution, queryCache])

  return (
    <Modal
      open={open}
      closeButton={false}
      onClose={onClose}
      shouldCloseOnEsc={false}
      shouldCloseOnOverlayClick={false}
    >
      <h3 className="text-h3 mb-16">Checking for automated feedback...</h3>
      {/* wait wait wait */}
      <div className="flex gap-8">
        <SubmitButton onClick={onSubmit} />
        <GoBackToExercise onClick={onClose} />
      </div>
    </Modal>
  )
}

function GoBackToExercise({ ...props }): JSX.Element {
  return (
    <button
      {...props}
      className="mr-16 px-[18px] py-[12px] border border-1 border-primaryBtnBorder text-primaryBtnBorder text-16 rounded-8 font-semibold shadow-xsZ1v2"
    >
      Go back to exercise
    </button>
  )
}
