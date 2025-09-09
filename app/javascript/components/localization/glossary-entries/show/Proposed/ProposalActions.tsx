import React, { useCallback, useContext } from 'react'
import { sendRequest } from '@/utils/send-request'
import { redirectTo } from '@/utils'
import { GlossaryEntriesShowContext } from '..'
import { useProposedContext } from './ProposedContext'

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

  const approveProposal = useCallback(
    async ({
      translationUuid,
      proposalUuid,
    }: {
      translationUuid: string
      proposalUuid: string
    }) => {
      try {
        const { fetch } = sendRequest({
          method: 'PATCH',
          endpoint: links.approveProposal
            .replace('GLOSSARY_ENTRY_ID', translationUuid)
            .replace('ID', proposalUuid),
          body: null,
        })

        await fetch
        redirectTo(links.glossaryEntriesListPage)
      } catch (err) {
        console.error(err)
      }
    },
    [links]
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
      try {
        const { fetch } = sendRequest({
          method: 'PATCH',
          endpoint: links.updateProposal
            .replace('GLOSSARY_ENTRY_ID', translationUuid)
            .replace('ID', proposalUuid),
          body: JSON.stringify({ value: proposalValue }),
        })

        await fetch
        redirectTo(links.glossaryEntriesListPage)
      } catch (err) {
        console.error(err)
      }
    },
    [links]
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
        const { fetch } = sendRequest({
          method: 'PATCH',
          endpoint: links.rejectProposal
            .replace('GLOSSARY_ENTRY_ID', translationUuid)
            .replace('ID', proposalUuid),
          body: null,
        })

        await fetch
        redirectTo(links.glossaryEntriesListPage)
      } catch (err) {
        console.error(err)
      }
    },
    [links]
  )

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
      ) : isOwn ? (
        <span>(This is your proposal so you cannot approve it)</span>
      ) : (
        <div className="flex gap-8 items-center">
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
