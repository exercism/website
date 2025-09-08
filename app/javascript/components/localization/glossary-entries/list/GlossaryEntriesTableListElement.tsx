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
  const { links } = React.useContext(GlossaryEntriesListContext)
  return (
    <a
      href={links?.localizationGlossaryEntriesPath + '/' + glossaryEntry.uuid}
      className="glossary-entry"
    >
      <div className="info">
        <div className="glossary-entry-key">{glossaryEntry.key}</div>
        <div className="glossary-entry-uuid">{glossaryEntry.prettyType}</div>
      </div>

      <TranslationsWithStatus translations={glossaryEntry.translations} />

      <div className="rhs">
        <div className="translation-glimpse">{glossaryEntry.value}</div>
        <GraphicalIcon
          icon="chevron-right"
          className="action-icon filter-textColor6"
        />
      </div>
    </a>
  )
}

export function TranslationsWithStatus({
  translations,
}: {
  translations: Original['translations']
}) {
  return (
    <div className="translations-statuses">
      {translations.map((translation) => (
        <div
          className={assembleClassNames(
            'translation-status',
            translation.status
          )}
          key={translation.uuid}
        >
          {flagForLocale(translation.locale)}
        </div>
      ))}
    </div>
  )
}
