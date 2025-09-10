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

      <TranslationsWithStatus
        locale={glossaryEntry.locale}
        status={glossaryEntry.status}
      />

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
  if (!mayCreateTranslationProposals && request.query.status === 'unchecked') {
    return (
      <span className="glossary-entry opacity-50 cursor-not-allowed">
        {content}
      </span>
    )
  }

  // on proposed page users without permission to manage proposals see disabled entries
  if (!mayManageTranslationProposals && request.query.status === 'proposed') {
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
  status: 'unchecked' | 'approved' | 'rejected' | 'proposed'
}) {
  return (
    <div className="translations-statuses">
      <div className={assembleClassNames('translation-status', status)}>
        {flagForLocale(locale)}
      </div>
    </div>
  )
}
