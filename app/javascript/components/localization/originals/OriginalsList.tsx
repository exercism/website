import React, { createContext, useEffect, useState } from 'react'
import { useLogger } from '@/components/bootcamp/common/hooks/useLogger'
import { FilterFallback, Pagination } from '@/components/common'
import GraphicalIcon from '@/components/common/GraphicalIcon'
import { SearchInput } from '@/components/common/SearchInput'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { flagForLocale } from '@/utils/flag-for-locale'
import { Request, usePaginatedRequestQuery } from '@/hooks/request-query'
import { useDebounce, useList } from '@uidotdev/usehooks'

type OriginalsListContextType = Pick<
  OriginalsListProps,
  'links' | 'originals' | 'request'
> & {
  selectedStatus: string
  setSelectedStatus: (tab: string) => void
  criteria?: string
  setCriteria: (criteria: string | undefined) => void
  page: number
  setPage: (page: number) => void
  resolvedData?: OriginalsListData
}

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

type OriginalsListData = {
  meta: {
    currentPage: number
    totalPages: number
    totalCount: number
    unscopedTotal: number
  }
  results: Original[]
}

export type OriginalsListProps = {
  originals: Original[]
  request: {
    endpoint: string
    query?: Record<string, any>
    options: {
      initialData: OriginalsListData
    }
  }
  links?: { localizationOriginalsPath: string; endpoint: string }
}

export default function OriginalsList({
  originals,
  links,
  request,
}: OriginalsListProps) {
  useLogger('originals', originals)

  const [selectedStatus, setSelectedStatus] = React.useState('unchecked')
  const [criteria, setCriteria] = useState<string | undefined>(undefined)
  const [page, setPage] = useState<number>(1)

  const {
    status,
    error,
    data: resolvedData,
    isFetching,
  } = usePaginatedRequestQuery<OriginalsListData>([CACHE_KEY, criteria], {
    endpoint: request.endpoint,
    query: { criteria },
    options: request.options,
  })

  useLogger('originals-list-query', {
    status,
    error,
    resolvedData,
    isFetching,
  })

  return (
    <OriginalsListContext.Provider
      value={{
        originals,
        request,
        resolvedData,
        links,
        selectedStatus,
        setSelectedStatus,
        criteria,
        setCriteria,
        setPage,
        page,
      }}
    >
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
  const { selectedStatus, setSelectedStatus } =
    React.useContext(OriginalsListContext)
  return (
    <div className="flex items-center tabs mb-16">
      {TABS.map((tab) => (
        <button
          key={tab.value}
          className={assembleClassNames(
            'c-tab',
            selectedStatus === tab.value && 'selected'
          )}
          onClick={() => setSelectedStatus(tab.value)}
        >
          {tab.label}
        </button>
      ))}
    </div>
  )
}

const CACHE_KEY = 'localization-originals-list'

export function Table() {
  const { setCriteria, criteria } = React.useContext(OriginalsListContext)

  const [inputValue, setInputValue] = React.useState(criteria || '')

  const debouncedValue = useDebounce(inputValue, 300)

  useEffect(() => {
    setCriteria(debouncedValue)
  }, [debouncedValue, setCriteria])

  return (
    <div className="originals-table">
      <Tabs />
      <div className="container">
        <header className="c-search-bar">
          <SearchInput
            setFilter={setInputValue}
            filter={inputValue}
            placeholder="Search for translation"
          />
        </header>
        <OriginalsTableList />
      </div>
    </div>
  )
}

function OriginalsTableList({}) {
  const { page, setPage, resolvedData } = React.useContext(OriginalsListContext)

  return (
    <>
      <div>
        {resolvedData &&
        resolvedData.results &&
        resolvedData.results.length > 0 ? (
          resolvedData.results.map((original, key) => (
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
        <Pagination
          disabled={true}
          current={page}
          total={1}
          setPage={setPage}
        />
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
