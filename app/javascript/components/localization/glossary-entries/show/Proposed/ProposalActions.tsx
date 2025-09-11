import React, { useCallback, useContext } from 'react'
import { redirectTo } from '@/utils'
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

  return (
    <div className="buttons">
      <div className="flex gap-8 items-center">
        <button
          type="button"
          className="btn-s btn-default"
          onClick={onEditMode}
        >
          Edit
        </button>
        {hasBeenEdited && (
          <button
            type="button"
            className="btn-s btn-default"
            onClick={onResetChanges}
          >
            Reset changes
          </button>
        )}
      </div>

      {hasBeenEdited ? (
        <div className="flex gap-8 items-center">
          <button
            type="button"
            className="btn-s btn-default"
            onClick={() => handleSkip()}
          >
            Skip
          </button>
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
      ) : isOwn ? (
        <div className="flex gap-8 items-center">
          <button
            type="button"
            className="btn-s btn-default"
            onClick={() => handleSkip()}
          >
            Skip
          </button>
          <span>(This is your proposal so you cannot approve it)</span>
        </div>
      ) : (
        <div className="flex gap-8 items-center">
          <button
            type="button"
            className="btn-s btn-default"
            onClick={() => handleSkip()}
          >
            Skip
          </button>
          <button
            type="button"
            className="btn-s btn-default"
            onClick={() =>
              approveProposal({
                translationUuid,
                proposalUuid: proposal.uuid,
              })
            }
          >
            Approve
          </button>
          <button
            type="button"
            className="btn-s btn-default"
            onClick={() =>
              rejectProposal({
                translationUuid,
                proposalUuid: proposal.uuid,
              })
            }
          >
            Reject
          </button>
        </div>
      )}
    </div>
  )
}
