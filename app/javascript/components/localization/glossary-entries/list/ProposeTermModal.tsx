import React from 'react'
import { Modal } from '@/components/modals'
import { sendRequest } from '@/utils/send-request'
import { useContext, useState, useCallback } from 'react'
import toast from 'react-hot-toast'
import { GlossaryEntriesListContext } from '.'
import { LocaleSelect } from './LocaleSelect'

export function ProposeTermModal({
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
      <div className="w-[500px]">
        <h2 className="text-h2 font-semibold mb-16">Propose New Term</h2>
        <div className="gap-20 flex flex-col">
          <div>
            <label className="block font-semibold mb-4 text-h6" htmlFor="term">
              Proposed Term (en)
            </label>
            <p className="text-p-base text-textColor6 leading-140">
              The English term you want to add to the glossary. Please check it
              does not already exist for your locale.
            </p>
            <input
              type="text"
              id="term"
              value={term}
              onChange={(e) => setTerm(e.target.value)}
              className="w-full border border-gray-300 rounded px-12 py-8"
              placeholder="Enter term"
            />
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
              className="w-full border border-gray-300 rounded px-12 py-8"
              placeholder="Enter translation"
            />
          </div>
          <div>
            <label
              className="block font-semibold mb-4 text-h6"
              htmlFor="description"
            >
              Description
            </label>
            <p className="text-p-base text-textColor6 leading-130 mb-8">
              Add sentence explaining why you chose this translation.
            </p>
            <textarea
              id="description"
              rows={2}
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              className="w-full border border-gray-300 rounded px-12 py-8"
              placeholder="Enter description"
            ></textarea>
          </div>
          <div className="flex items-center gap-8">
            <button
              onClick={onSave}
              type="submit"
              className="btn btn-primary btn-m"
            >
              Propose new term
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
