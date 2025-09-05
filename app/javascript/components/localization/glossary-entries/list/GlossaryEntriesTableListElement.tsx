import React from 'react'
import { GraphicalIcon } from '@/components/common'
import { GlossaryEntriesListContext } from '.'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { flagForLocale } from '@/utils/flag-for-locale'

export function GlossaryEntriesTableListElement({
  original,
}: {
  original: Original
}) {
  const { links } = React.useContext(GlossaryEntriesListContext)
  return (
    <a
      href={links?.localizationGlossaryEntriesPath + '/' + original.uuid}
      className="original"
    >
      <div className="info">
        <div className="original-key">{original.title}</div>
        <div className="original-uuid">{original.prettyType}</div>
      </div>

      <TranslationsWithStatus translations={original.translations} />

      <div className="rhs">
        <div className="translation-glimpse">{original.value}</div>
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
