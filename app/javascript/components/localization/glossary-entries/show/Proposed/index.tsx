import React, {
  createContext,
  useCallback,
  useContext,
  useMemo,
  useState,
} from 'react'
import { flagForLocale } from '@/utils/flag-for-locale'
import { nameForLocale } from '@/utils/name-for-locale'
import { sendRequest } from '@/utils/send-request'
import { redirectTo } from '@/utils'
import { ProposalDescription } from './ProposalDescription'
import { FeedbackBlock } from './FeedbackBlock'
import { GlossaryEntriesShowContext } from '..'

export type LLMFeedback = {
  result: 'approved' | 'rejected'
  reason: string
}

export type Proposal = {
  uuid: string
  value: string
  proposerId: string | number
  modifiedFromLLM?: boolean
  llmFeedback?: LLMFeedback | null
  reviewerId?: string | number | null
}

type Translation = {
  status: 'proposed'
  locale: string
  proposals: Proposal[]
  uuid: string
}

type ProposedProps = {
  translation: Translation
  currentUserId: string | number
  onApproveProposal: (params: { locale: string; proposalIndex: number }) => void
  onRejectProposal: (params: { locale: string; proposalIndex: number }) => void
  onEditProposal: (params: { locale: string; proposalIndex: number }) => void
}

type ProposalCardContextType = {
  editMode: boolean
  setEditMode: (editMode: boolean) => void
}

const ProposalCardContext = createContext<ProposalCardContextType>(
  {} as ProposalCardContextType
)

/*
approve_llm_version_api_localization_translation  PATCH    /api/v2/localization/translations/:id/approve_llm_version(.:format)                                                           api/localization/translations#approve_llm_version
approve_api_localization_translation_proposal     PATCH    /api/v2/localization/translations/:translation_id/proposals/:id/approve(.:format)                                             api/localization/translation_proposals#approve
reject_api_localization_translation_proposal      PATCH    /api/v2/localization/translations/:translation_id/proposals/:id/reject(.:format)                                              api/localization/translation_proposals#reject
api_localization_translation_proposals            POST     /api/v2/localization/translations/:translation_id/proposals(.:format)                                                         api/localization/translation_proposals#create
api_localization_translation_proposal             PATCH    /api/v2/localization/translations/:translation_id/proposals/:id(.:format)                                                     api/localization/translation_proposals#update
*/

// Approve: PATCH approve_api_localization_translation_proposal
// Reject: PATCH reject_api_localization_translation_proposal
// after editing Update proposal: PATCH api_localization_translation_proposal
export function Proposed({ translation }: ProposedProps) {
  const { locale, proposals } = translation

  return (
    <section className="locale proposed">
      <TranslationHeader locale={locale} />
      <div className="body">
        {proposals.length > 1 && (
          <p className="text-16 leading-140 mb-10">
            There have been multiple proposals for this translation. Please
            review the proposals. If one is correct, please approve it (which
            will reject the others). Or if none are correct, reject each of
            them, then edit the original LLM output yourself.
          </p>
        )}

        <div className="flex flex-col gap-12">
          {proposals.map((proposal, idx) => (
            <ProposalCard
              key={proposal.uuid || idx}
              proposal={proposal}
              locale={locale}
              isMultiple={proposals.length > 1}
              translationUuid={translation.uuid}
            />
          ))}
        </div>
      </div>
    </section>
  )
}

function TranslationHeader({ locale }: { locale: string }) {
  return (
    <div className="header">
      <div className="text-h4">
        {nameForLocale(locale)} ({locale})
      </div>
      <div className="status">Needs Reviewing</div>
      <div className="flag">{flagForLocale(locale)}</div>
    </div>
  )
}

function ProposalCard({
  proposal,
  locale,
  isMultiple,
  translationUuid,
}: {
  proposal: Proposal
  locale: string
  isMultiple: boolean
  translationUuid: string
}) {
  const { currentUserId } = useContext(GlossaryEntriesShowContext)
  const isOwn = String(proposal.proposerId) === String(currentUserId)

  const cardClasses = isMultiple
    ? 'border-1 border-borderColor5 p-12 rounded-8 bg-backgroundColorF shadow-keystroke'
    : ''

  const [editMode, setEditMode] = useState(false)
  const [proposalValue, setProposalValue] = useState(proposal.value)
  const [editorValue, setEditorValue] = useState(proposal.value)

  const hasBeenEdited = useMemo(() => {
    return proposalValue !== proposal.value
  }, [proposalValue])

  const onSaveEditing = useCallback(() => {
    setProposalValue(editorValue)
    setEditMode(false)
  }, [editorValue])
  const onCancelEditing = useCallback(() => {
    setEditMode(false)
    setEditorValue(proposalValue)
  }, [proposalValue])

  const onResetChanges = useCallback(() => {
    setEditorValue(proposal.value)
    setProposalValue(proposal.value)
  }, [])

  return (
    <ProposalCardContext.Provider value={{ editMode, setEditMode }}>
      <div className={cardClasses}>
        {!isMultiple && (
          <ProposalDescription proposal={proposal} locale={locale} />
        )}

        {editMode ? (
          <textarea
            className="local-value mb-12 w-full"
            rows={12}
            value={editorValue}
            onChange={(e) => setEditorValue(e.target.value)}
          />
        ) : (
          <div className="locale-value mb-12 !bg-white">{proposalValue}</div>
        )}

        {proposal.llmFeedback && (
          <FeedbackBlock feedback={proposal.llmFeedback} />
        )}

        {editMode ? (
          <EditActions onSave={onSaveEditing} onCancel={onCancelEditing} />
        ) : (
          <ProposalActions
            isOwn={isOwn}
            proposalValue={proposalValue}
            onResetChanges={onResetChanges}
            hasBeenEdited={hasBeenEdited}
            uuids={{ proposal: proposal.uuid, translation: translationUuid }}
          />
        )}
      </div>
    </ProposalCardContext.Provider>
  )
}

function ProposalActions({
  isOwn,
  uuids,
  onResetChanges,
  hasBeenEdited,
  proposalValue = '',
}: {
  isOwn: boolean
  uuids: { proposal: string; translation: string }
  onResetChanges: () => void
  hasBeenEdited?: boolean
  proposalValue: string
}) {
  const { setEditMode } = useContext(ProposalCardContext)
  const { links } = useContext(GlossaryEntriesShowContext)

  const approveProposal = useCallback(
    async ({ translationUuid, proposalUuid }) => {
      try {
        const { fetch } = sendRequest({
          method: 'PATCH',
          endpoint: links.approveProposal
            .replace('TRANSLATION_ID', translationUuid)
            .replace('PROPOSAL_ID', proposalUuid),
          body: null,
        })

        await fetch
        redirectTo(links.originalsListPage)
      } catch (err) {
        console.error(err)
      }
    },
    []
  )

  const updateProposal = useCallback(
    async ({ translationUuid, proposalUuid, proposalValue }) => {
      try {
        const { fetch } = sendRequest({
          method: 'PATCH',
          endpoint: links.updateProposal
            .replace('TRANSLATION_ID', translationUuid)
            .replace('PROPOSAL_ID', proposalUuid),
          body: JSON.stringify({ value: proposalValue }),
        })

        await fetch
        redirectTo(links.originalsListPage)
      } catch (err) {
        console.error(err)
      }
    },
    []
  )

  const rejectProposal = useCallback(
    async ({ translationUuid, proposalUuid }) => {
      try {
        const { fetch } = sendRequest({
          method: 'PATCH',
          endpoint: links.rejectProposal
            .replace('TRANSLATION_ID', translationUuid)
            .replace('PROPOSAL_ID', proposalUuid),
          body: null,
        })

        await fetch
        redirectTo(links.originalsListPage)
      } catch (err) {
        console.error(err)
      }
    },
    []
  )

  return (
    <div className="buttons">
      <div className="flex gap-8 items-center">
        <button
          type="button"
          className="btn-s btn-default"
          onClick={() => setEditMode(true)}
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
              translationUuid: uuids.translation,
              proposalUuid: uuids.proposal,
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
                translationUuid: uuids.translation,
                proposalUuid: uuids.proposal,
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
                translationUuid: uuids.translation,
                proposalUuid: uuids.proposal,
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

function EditActions({ onSave, onCancel }) {
  return (
    <div className="flex gap-8 items-center">
      <button type="button" className="btn-s btn-primary" onClick={onSave}>
        Save
      </button>
      <button type="button" className="btn-s btn-default" onClick={onCancel}>
        Cancel
      </button>
    </div>
  )
}
