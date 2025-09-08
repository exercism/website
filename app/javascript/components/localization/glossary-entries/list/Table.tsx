import { SearchInput } from '@/components/common'
import { useDebounce } from '@uidotdev/usehooks'
import React, { useCallback, useEffect, useState } from 'react'
import { GlossaryEntriesListContext } from '.'
import { GlossaryEntriesTableList } from './GlossaryEntriesTableList'
import { Tabs } from './Tabs'
import { Modal } from '@/components/modals'
import { sendRequest } from '@/utils/send-request'
import { Toaster, toast } from 'react-hot-toast'

export function Table() {
  const { setCriteria, request } = React.useContext(GlossaryEntriesListContext)

  const [isOpen, setIsOpen] = React.useState(false)

  const [inputValue, setInputValue] = React.useState(
    request.query.criteria || ''
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
        <header className="c-search-bar">
          <SearchInput
            setFilter={setInputValue}
            filter={inputValue}
            placeholder="Search for translation"
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
  return (
    <button onClick={onClick} className="btn btn-primary btn-m">
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
  const [term, setTerm] = useState<string>('')
  const [description, setDescription] = useState<string>('')

  const onSave = useCallback(() => {
    const fetch = sendRequest({
      endpoint: '',
      method: 'POST',
      body: JSON.stringify({ term, description }),
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
  }, [term, description])

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

            {/* GENERATE NOTE ABOUT WHAT A GLOSSARY TERM IS*/}
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
            {/* GENERATE NOTE ABOUT WHAT A GLOSSARY TERM DESCRIPTION IS*/}
            <p className="text-p text-textColor6 leading-130">
              A glossary term description provides additional context or
              explanation about the term, helping users understand its usage and
              significance.
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
