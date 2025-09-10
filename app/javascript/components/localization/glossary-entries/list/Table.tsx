import { SearchInput } from '@/components/common'
import { useDebounce } from '@uidotdev/usehooks'
import React, { useCallback, useContext, useEffect, useState } from 'react'
import { GlossaryEntriesListContext } from '.'
import { GlossaryEntriesTableList } from './GlossaryEntriesTableList'
import { Tabs } from './Tabs'
import { Modal } from '@/components/modals'
import { sendRequest } from '@/utils/send-request'
import { Toaster, toast } from 'react-hot-toast'
import { LocaleSelect } from './LocaleSelect'

export function Table() {
  const { setCriteria, request, translationLocales, setQuery } =
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
  }, [debouncedValue, setCriteria])

  return (
    <div className="originals-table">
      <div className="flex items-center justify-between mb-16">
        <Tabs />
        <ProposeTermButton
          onClick={() => {
            setIsOpen(true)
          }}
        />
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
      <ProposeTermModal
        isOpen={isOpen}
        onClose={() => {
          setIsOpen(false)
        }}
      />
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
      + Propose
    </button>
  )
}

function ProposeTermModal({
  isOpen,
  onClose,
}: {
  isOpen: boolean
  onClose: () => void
}) {
  const { links, translationLocales } = useContext(GlossaryEntriesListContext)
  const [term, setTerm] = useState<string>('')
  const [description, setDescription] = useState<string>('')
  const [locale, setLocale] = useState<string>(translationLocales[0])
  const [translation, setTranslation] = useState<string>('')

  const onSave = useCallback(() => {
    const fetch = sendRequest({
      endpoint: links.createGlossaryEntry,
      method: 'POST',
      body: JSON.stringify({
        glossary_entry: {
          term,
          llm_instructions: description,
          locale,
          translation,
        },
      }),
    })

    fetch.fetch
      .then(() => {
        onClose()
        toast.success('Proposed a new term successfully!')
      })
      .catch((e) => {
        toast.error('Failed to propose a new term.', e)
        console.error(e)
      })
  }, [term, description, locale, translation])

  return (
    <Modal open={isOpen} onClose={onClose}>
      <div className="w-[400px]">
        <h2 className="text-h2 font-bold mb-16">Propose New Term</h2>
        <div className="gap-16 flex flex-col">
          <div>
            <label className="block font-semibold mb-4 text-h6" htmlFor="term">
              Term
            </label>
            <input
              type="text"
              id="term"
              value={term}
              onChange={(e) => setTerm(e.target.value)}
              className="w-full border border-gray-300 rounded px-12 py-8 mb-8"
              placeholder="Enter term"
            />

            <p className="text-p text-textColor6 leading-130">
              A glossary term is a word or phrase that has a specific meaning
              within a particular context or field.
            </p>
          </div>
          <div>
            <label
              className="block font-semibold mb-4 text-h6"
              htmlFor="description"
            >
              Description
            </label>
            <textarea
              id="description"
              rows={4}
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              className="w-full border border-gray-300 rounded px-12 py-8 mb-8"
              placeholder="Enter description"
            ></textarea>
            <p className="text-p text-textColor6 leading-130">
              A glossary term description provides additional context or
              explanation about the term, helping users understand its usage and
              significance.
            </p>
          </div>
          <div>
            <label className="block font-semibold mb-4 text-h6">Locale</label>
            <LocaleSelect
              locales={[...(translationLocales || [])]}
              value={locale}
              onChange={(locale) => setLocale(locale)}
              showAll={false}
              label="Select locale"
            />
            <p className="text-p text-textColor6 leading-130 mt-8">
              Select the language locale for this glossary term.
            </p>
          </div>
          <div>
            <label
              className="block font-semibold mb-4 text-h6"
              htmlFor="translation"
            >
              Translation
            </label>
            <input
              type="text"
              id="translation"
              value={translation}
              onChange={(e) => setTranslation(e.target.value)}
              className="w-full border border-gray-300 rounded px-12 py-8 mb-8"
              placeholder="Enter translation"
            />
            <p className="text-p text-textColor6 leading-130">
              Provide the translated term or phrase in the selected locale.
            </p>
          </div>
          <div className="flex items-center gap-8">
            <button
              onClick={onSave}
              type="submit"
              className="btn btn-primary btn-m"
            >
              Save
            </button>
            <button
              type="button"
              className="btn btn-secondary btn-m"
              onClick={onClose}
            >
              Cancel
            </button>
          </div>
        </div>
      </div>
    </Modal>
  )
}
