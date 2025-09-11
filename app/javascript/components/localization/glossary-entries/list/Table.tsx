import { SearchInput } from '@/components/common'
import { useDebounce } from '@uidotdev/usehooks'
import React, { useCallback, useContext, useEffect, useState } from 'react'
import { GlossaryEntriesListContext } from '.'
import { GlossaryEntriesTableList } from './GlossaryEntriesTableList'
import { Tabs } from './Tabs'
import { Toaster } from 'react-hot-toast'
import { LocaleSelect } from './LocaleSelect'
import { ProposeTermModal } from './ProposeTermModal'

export function Table() {
  const { setCriteria, request, translationLocales, setQuery, setPage } =
    React.useContext(GlossaryEntriesListContext)

  const [isOpen, setIsOpen] = React.useState(false)

  const [inputValue, setInputValue] = React.useState(
    request.query.criteria || ''
  )
  const [selectedLocale, setSelectedLocale] = React.useState(
    request.query.filter_locale || ''
  )
  const debouncedValue = useDebounce(inputValue, 300)

  useEffect(() => {
    setCriteria(debouncedValue)
    setPage(0)
  }, [debouncedValue, setCriteria])

  return (
    <div className="originals-table">
      <div className="flex items-center justify-between mb-16">
        <Tabs />
        {/* <ProposeTermButton
          onClick={() => {
            setIsOpen(true)
          }}
        /> */}
      </div>

      <div className="container">
        <header className="c-search-bar flex items-center justify-between">
          <SearchInput
            setFilter={setInputValue}
            filter={inputValue}
            placeholder="Search for translation"
          />
          <LocaleSelect
            locales={translationLocales || []}
            value={selectedLocale}
            onChange={(locale) => {
              setSelectedLocale(locale)
              setQuery({
                ...request.query,
                filter_locale: locale || undefined,
                page: null,
              })
            }}
          />
        </header>
        <GlossaryEntriesTableList />
      </div>
      {/* <ProposeTermModal
        isOpen={isOpen}
        onClose={() => {
          setIsOpen(false)
        }}
      /> */}
      <Toaster />
    </div>
  )
}

function ProposeTermButton({ onClick }) {
  const { mayCreateTranslationProposals } = useContext(
    GlossaryEntriesListContext
  )
  return (
    <button
      disabled={!mayCreateTranslationProposals}
      onClick={onClick}
      className="btn btn-primary btn-m"
    >
      Propose new term
    </button>
  )
}
