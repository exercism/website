import { useLogger } from '@/components/bootcamp/common/hooks/useLogger'
import { FilterFallback, Pagination } from '@/components/common'
import GraphicalIcon from '@/components/common/GraphicalIcon'
import { SearchInput } from '@/components/common/SearchInput'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { flagForLocale } from '@/utils/flag-for-locale'
import React, { createContext, useState } from 'react'

type OriginalsListContextType = Pick<OriginalsListProps, 'links' | 'originals'>

type Original = {
  uuid: string
  key: string
  value: string
  translations: {
    uuid: string
    locale: string
    status: string
  }[]
}

export const OriginalsListContext = createContext<OriginalsListContextType>(
  {} as OriginalsListContextType
)

export type OriginalsListProps = {
  originals: Original[]
  links?: { localizationOriginalsPath: string }
}

export default function OriginalsList({
  originals,
  links,
}: OriginalsListProps) {
  useLogger('originals', originals)

  return (
    <OriginalsListContext.Provider value={{ originals, links }}>
      <Table />
    </OriginalsListContext.Provider>
  )
}

const TABS = [
  {
    value: 'unchecked',
    label: 'Needs translating',
  },
  { value: 'proposed', label: 'Needs reviewing' },
  { value: 'checked', label: 'Done' },
]
export function Tabs() {
  const [selectedTab, setSelectedTab] = React.useState('unchecked')
  return (
    <div className="flex items-center tabs mb-16">
      {TABS.map((tab) => (
        <button
          key={tab.value}
          className={assembleClassNames(
            'c-tab',
            selectedTab === tab.value && 'selected'
          )}
          onClick={() => setSelectedTab(tab.value)}
        >
          {tab.label}
        </button>
      ))}
    </div>
  )
}

export function Table() {
  const [criteria, setCriteria] = useState<string | undefined>(undefined)

  return (
    <div className="originals-table">
      <Tabs />
      <div className="container">
        <header className="c-search-bar">
          <SearchInput
            setFilter={(input) => {
              setCriteria(input)
            }}
            filter={criteria || ''}
            placeholder="Search for translation"
          />
        </header>
        <OriginalsTableList />
      </div>
    </div>
  )
}

function OriginalsTableList({}) {
  const { originals } = React.useContext(OriginalsListContext)
  return (
    <>
      <div>
        {originals.length > 0 ? (
          originals.map((original, key) => (
            <OriginalsTableListElement original={original} key={key} />
          ))
        ) : (
          <FilterFallback
            icon="no-result-magnifier"
            title="No originals found."
            description="Try changing your filters to find originals that need checking."
          />
        )}
      </div>
      <footer>
        <Pagination disabled={true} current={1} total={1} setPage={(p) => {}} />
      </footer>
    </>
  )
}

function OriginalsTableListElement({ original }: { original: Original }) {
  const { links } = React.useContext(OriginalsListContext)
  useLogger('links', links)
  return (
    <a
      href={links?.localizationOriginalsPath + '/' + original.uuid}
      className="original"
    >
      <div className="info">
        <div className="original-key">{original.key}</div>
        <div className="original-uuid">{original.uuid}</div>
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

function TranslationsWithStatus({
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
