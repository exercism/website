import React from 'react'
import { GraphicalIcon } from '@/components/common'
import { GlossaryEntriesListContext } from '.'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { flagForLocale } from '@/utils/flag-for-locale'

const GlossaryEntryStatusTags = {
  unchecked: 'Needs checking',
  checked: 'Done',
  proposed: 'Needs Sign Off',
}

export function GlossaryEntriesTableListElement({
  glossaryEntry,
}: {
  glossaryEntry: GlossaryEntry
}) {
  const {
    links,
    mayCreateTranslationProposals,
    mayManageTranslationProposals,
  } = React.useContext(GlossaryEntriesListContext)

  const content = (
    <>
      <div className="info">
        <div className="glossary-entry-key w-[600px]">
          {glossaryEntry.term} → {glossaryEntry.translation}
        </div>
      </div>

      <div className="text-20">{flagForLocale(glossaryEntry.locale)}</div>
      <div className="text-15 font-semibold text-textColor6 w-[50px] flex-shrink-0">
        {glossaryEntry.locale}
      </div>

      <div className="w-[200px] flex-shrink-0">
        <div
          className={assembleClassNames(
            'translation-status',
            glossaryEntry.status
          )}
        >
          {GlossaryEntryStatusTags[glossaryEntry.status]}
        </div>
      </div>

      <div className="translation-glimpse ml-auto">
        {glossaryEntry.llmInstructions}
      </div>
      <GraphicalIcon
        icon="chevron-right"
        className="action-icon filter-textColor6"
      />
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
