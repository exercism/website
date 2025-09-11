import React from 'react'
import { GraphicalIcon } from '@/components/common'
import { GlossaryEntriesListContext } from '.'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { flagForLocale } from '@/utils/flag-for-locale'

export function GlossaryEntriesTableListElement({
  glossaryEntry,
}: {
  glossaryEntry: GlossaryEntry
}) {
  const {
    links,
    mayCreateTranslationProposals,
    mayManageTranslationProposals,
    request,
  } = React.useContext(GlossaryEntriesListContext)

  const content = (
    <>
      <div className="info">
        <div className="glossary-entry-key w-[600px]">
          {glossaryEntry.term} → {glossaryEntry.translation}
        </div>
      </div>

      <div className="text-20">{flagForLocale(glossaryEntry.locale)}</div>
      <div className="text-15 font-semibold text-textColor6 w-[50px] flex-shrink-0">{glossaryEntry.locale}</div>

      {/* Aron - apply the same colors that were on the flag to these and render the correct one */}
      {/* Aron - Set the width to be the same on all of them with a flex-shrink-0, or put them in an outer div with that*/}
      <div className="text-[13px] upcase font-semibold border-1 rounded-100 px-8 py-6">{glossaryEntry.status}</div>
      <div className="text-[13px] upcase font-semibold border-1 rounded-100 px-8 py-6">Needs checking</div>
      <div className="text-[13px] upcase font-semibold border-1 rounded-100 px-8 py-6">Needs Sign Off</div>
      <div className="text-[13px] upcase font-semibold border-1 rounded-100 px-8 py-6">Done</div>

      <div className="rhs">
        <div className="translation-glimpse">
          {glossaryEntry.llmInstructions}
        </div>
        <GraphicalIcon
          icon="chevron-right"
          className="action-icon filter-textColor6"
        />
      </div>
    </>
  )

  // on unchecked page users without permission to create proposals see disabled entries
  if (!mayCreateTranslationProposals && glossaryEntry.status === 'unchecked') {
    return (
      <span className="glossary-entry opacity-50 cursor-not-allowed">
        {content}
      </span>
    )
  }

  // on proposed page users without permission to manage proposals see disabled entries
  if (!mayManageTranslationProposals && glossaryEntry.status === 'proposed') {
    return (
      <span className="glossary-entry opacity-50 cursor-not-allowed">
        {content}
      </span>
    )
  }
  return (
    <a
      href={links?.localizationGlossaryEntriesPath + '/' + glossaryEntry.uuid}
      className="glossary-entry"
    >
      {content}
    </a>
  )
}

export function TranslationsWithStatus({
  locale,
  status,
}: {
  locale: string
  status: 'unchecked' | 'checked' | 'proposed'
}) {
  return (
    <div className="translations-statuses">
      <div className={assembleClassNames('translation-status', status)}>
        {flagForLocale(locale)}
      </div>
    </div>
  )
}
