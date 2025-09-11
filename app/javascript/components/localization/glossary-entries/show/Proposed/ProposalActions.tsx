import React, { useCallback, useContext } from 'react'
import { GlossaryEntriesShowContext } from '..'
import { useProposedContext } from './ProposedContext'
import { useRequestWithNextRedirect } from '../useRequestWithNextRedirect'

type ProposalActionsProps = {
  proposal: Proposal
  isOwn: boolean
  proposalValue: string
  hasBeenEdited: boolean
  onResetChanges: () => void
  onEditMode: () => void
}

export function ProposalActions({
  proposal,
  isOwn,
  proposalValue,
  hasBeenEdited,
  onResetChanges,
  onEditMode,
}: ProposalActionsProps) {
  const { links } = useContext(GlossaryEntriesShowContext)
  const { uuid: translationUuid } = useProposedContext()
  const { sendRequestWithRedirect, redirectToNext } =
    useRequestWithNextRedirect()

  const approveProposal = useCallback(
    async ({
      translationUuid,
      proposalUuid,
    }: {
      translationUuid: string
      proposalUuid: string
    }) => {
      try {
        await sendRequestWithRedirect({
          method: 'PATCH',
          endpoint: links.approveProposal
            .replace('GLOSSARY_ENTRY_ID', translationUuid)
            .replace('ID', proposalUuid),
          body: null,
        })
      } catch (err) {
        console.error(err)
      }
    },
    [sendRequestWithRedirect, links]
  )

  const updateProposal = useCallback(
    async ({
      translationUuid,
      proposalUuid,
      proposalValue,
    }: {
      translationUuid: string
      proposalUuid: string
      proposalValue: string
    }) => {
      await sendRequestWithRedirect({
        method: 'PATCH',
        endpoint: links.updateProposal
          .replace('GLOSSARY_ENTRY_ID', translationUuid)
          .replace('ID', proposalUuid),
        body: JSON.stringify({ value: proposalValue }),
      })
    },
    [sendRequestWithRedirect, links]
  )

  const rejectProposal = useCallback(
    async ({
      translationUuid,
      proposalUuid,
    }: {
      translationUuid: string
      proposalUuid: string
    }) => {
      try {
        await sendRequestWithRedirect({
          method: 'PATCH',
          endpoint: links.rejectProposal
            .replace('GLOSSARY_ENTRY_ID', translationUuid)
            .replace('ID', proposalUuid),
          body: null,
        })
      } catch (err) {
        console.error(err)
      }
    },
    [sendRequestWithRedirect, links]
  )

  const handleSkip = useCallback(async () => {
    try {
      await redirectToNext()
    } catch (err) {
      console.error('Error skipping to next entry:', err)
    }
  }, [redirectToNext])

  const SkipButton = ({
    children = 'Skip',
  }: {
    children?: React.ReactNode
  }) => (
    <button type="button" className="btn-s btn-default" onClick={handleSkip}>
      {children}
    </button>
  )

  const EditButton = () => (
    <button type="button" className="btn-s btn-default" onClick={onEditMode}>
      Edit translation
    </button>
  )

  const ResetButton = () => (
    <button
      type="button"
      className="btn-s btn-default"
      onClick={onResetChanges}
    >
      Reset changes
    </button>
  )

  const renderRightActions = () => {
    if (hasBeenEdited) {
      return (
        <div className="flex gap-8 items-center">
          <SkipButton />
          <button
            type="button"
            className="btn-s btn-primary"
            onClick={() =>
              updateProposal({
                translationUuid,
                proposalUuid: proposal.uuid,
                proposalValue,
              })
            }
          >
            Update proposal
          </button>
        </div>
      )
    }

    if (isOwn) {
      return (
        <div className="flex gap-8 items-center">
          <SkipButton />
          <span>(This is your proposal so you cannot approve it)</span>
        </div>
      )
    }

    return (
      <div className="flex gap-8 items-center">
        <SkipButton>Skip this entry</SkipButton>
        <button
          type="button"
          className="btn-s btn-warning"
          onClick={() =>
            rejectProposal({
              translationUuid,
              proposalUuid: proposal.uuid,
            })
          }
        >
          Reject
        </button>
        <button
          type="button"
          className="btn-s btn-primary"
          onClick={() =>
            approveProposal({
              translationUuid,
              proposalUuid: proposal.uuid,
            })
          }
        >
          👍 Sign Off
        </button>
      </div>
    )
  }

  return (
    <div className="buttons">
      <div className="flex gap-8 items-center">
        <EditButton />
        {hasBeenEdited && <ResetButton />}
      </div>
      {renderRightActions()}
    </div>
  )
}
