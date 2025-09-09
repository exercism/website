import React from 'react'
import { ProposedProvider } from './ProposedContext'
import { TranslationHeader } from './TranslationHeader'
import { ProposalCard } from './ProposalCard'

type ProposedProps = {
  uuid: string
  locale: string
  translation: string
  status: string
  llmInstructions: string
  proposals: Proposal[]
  currentUserId: string | number
}

export function Proposed(props: ProposedProps) {
  const { locale, proposals } = props

  return (
    <ProposedProvider value={props}>
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
                isMultiple={proposals.length > 1}
              />
            ))}
          </div>
        </div>
      </section>
    </ProposedProvider>
  )
}
