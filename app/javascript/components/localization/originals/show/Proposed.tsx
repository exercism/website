import React, { useContext } from 'react'
import { flagForLocale } from '@/utils/flag-for-locale'
import { nameForLocale } from '@/utils/name-for-locale'
import { OriginalsShowContext } from '.'

type LLMFeedback = {
  result: 'approved' | 'rejected'
  reason: string
}

type Proposal = {
  value: string
  proposerId: string | number
  modifiedFromLLM?: boolean
  llmFeedback?: LLMFeedback | null
}

type Translation = {
  status: 'proposed'
  locale: string
  proposals: Proposal[]
}

type ProposedProps = {
  translation: Translation
  currentUserId: string | number
}

export function Proposed({ translation }: ProposedProps) {
  const { locale, proposals } = translation
  return (
    <section className="locale proposed">
      <div className="header">
        <div className="text-h4">
          {nameForLocale(translation.locale)} ({locale})
        </div>
        <div className="status">Needs Reviewing</div>
        <div className="flag">{flagForLocale(locale)}</div>
      </div>

      <div className="body">
        {proposals.length === 1 ? (
          <SingleProposal proposal={proposals[0]} idx={0} />
        ) : (
          <MultipleProposals proposals={proposals} />
        )}
      </div>
    </section>
  )
}

function MultipleProposals({ proposals }: { proposals: Proposal[] }) {
  const { currentUserId } = React.useContext(OriginalsShowContext)
  return (
    <>
      <p className="text-16 leading-140 mb-10">
        There have been multiple proposals for this translation. Please review
        the proposals. If one is correct, please approve it (which will reject
        the others). Or if none are correct, reject each of them, then edit the
        original LLM output yourself.
      </p>

      <div className="flex flex-col gap-12">
        {proposals.map((proposal, idx) => {
          const mine = String(proposal.proposerId) === String(currentUserId)
          return (
            <div
              key={idx}
              className="border-1 border-borderColor5 p-12 rounded-8 bg-backgroundColorF shadow-keystroke"
            >
              <div className="locale-value mb-12 !bg-white">
                {proposal.value}
              </div>

              {proposal.llmFeedback && (
                <FeedbackBlock feedback={proposal.llmFeedback} />
              )}

              <div className="buttons">
                {mine ? (
                  <>
                    <button
                      type="button"
                      className="btn-s btn-default"
                      onClick={() =>
                        onEditProposal?.({ locale, proposalIndex: idx })
                      }
                    >
                      Edit
                    </button>{' '}
                    <span>
                      (This is your proposal so you cannot approve it)
                    </span>
                  </>
                ) : (
                  <>
                    <button
                      type="button"
                      className="btn-s btn-default"
                      onClick={() =>
                        onApproveProposal?.({ locale, proposalIndex: idx })
                      }
                    >
                      Approve
                    </button>
                    <button
                      type="button"
                      className="btn-s btn-default"
                      onClick={() =>
                        onRejectProposal?.({ locale, proposalIndex: idx })
                      }
                    >
                      Reject
                    </button>
                    <button
                      type="button"
                      className="btn-s btn-default"
                      onClick={() =>
                        onEditProposal?.({ locale, proposalIndex: idx })
                      }
                    >
                      Edit
                    </button>
                  </>
                )}
              </div>
            </div>
          )
        })}
      </div>
    </>
  )
}

function FeedbackBlock({ feedback }: { feedback: LLMFeedback }) {
  if (feedback.result === 'approved') {
    return (
      <div className="llm-feedback approved">
        <div className="tick">✅</div>
        <div className="text">
          {feedback.reason}
          <div className="byline">
            This is automatically generated feedback.
          </div>
        </div>
      </div>
    )
  }
  return (
    <div className="llm-feedback rejected">
      <div className="img">❌</div>
      <div className="text">
        {feedback.reason}
        <div className="byline">This is automatically generated feedback.</div>
      </div>
    </div>
  )
}

function SingleProposal({
  proposal,
  idx,
}: {
  proposal: Proposal
  idx: number
}) {
  const { currentUserId } = useContext(OriginalsShowContext)
  const mine = String(proposal.proposerId) === String(currentUserId)

  return (
    <>
      <p className="text-16 leading-140 mb-10">
        {proposal.modifiedFromLLM ? (
          <>
            This is a proposal from a translator who has modified the
            LLM-generated translation.
          </>
        ) : (
          <>
            This is the <span>{proposal.locale}</span> version of the English
            text on the right. It was generated by an LLM and reviewed by
            another translator who has marked it as correct.
          </>
        )}{' '}
        Please compare it to the original and either approve it, reject it, or
        edit it further.
      </p>

      <div className="locale-value mb-12">{proposal.value}</div>

      {proposal.llmFeedback && (
        <FeedbackBlock feedback={proposal.llmFeedback} />
      )}

      <div className="buttons">
        {mine ? (
          <>
            <button
              type="button"
              className="btn-s btn-default"
              onClick={() => onEditProposal?.({ locale, proposalIndex: idx })}
            >
              Edit
            </button>{' '}
            <span>(This is your proposal so you cannot approve it)</span>
          </>
        ) : (
          <>
            <button
              type="button"
              className="btn-s btn-default"
              onClick={() =>
                onApproveProposal?.({ locale, proposalIndex: idx })
              }
            >
              Approve
            </button>
            <button
              type="button"
              className="btn-s btn-default"
              onClick={() => onRejectProposal?.({ locale, proposalIndex: idx })}
            >
              Reject
            </button>
            <button
              type="button"
              className="btn-s btn-default"
              onClick={() => onEditProposal?.({ locale, proposalIndex: idx })}
            >
              Edit
            </button>
          </>
        )}
      </div>
    </>
  )
}
