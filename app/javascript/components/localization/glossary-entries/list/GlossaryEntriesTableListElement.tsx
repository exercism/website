import React from 'react'
import { GraphicalIcon } from '@/components/common'
import { GlossaryEntriesListContext } from '.'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { flagForLocale } from '@/utils/flag-for-locale'
import { useLogger } from '@/components/bootcamp/common/hooks/useLogger'

export function GlossaryEntriesTableListElement({
  glossaryEntry,
}: {
  glossaryEntry: GlossaryEntry
}) {
  const { links } = React.useContext(GlossaryEntriesListContext)
  useLogger('glossaryEntry', glossaryEntry)
  return (
    <a
      href={links?.localizationGlossaryEntriesPath + '/' + glossaryEntry.uuid}
      className="glossary-entry"
    >
      <div className="info">
        <div className="glossary-entry-key w-[600px]">
          {glossaryEntry.term} → {glossaryEntry.translation}
        </div>
        {/* <div className="glossary-entry-uuid">{glossaryEntry.uuid}</div> */}
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
