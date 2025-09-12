/// <reference path="../types.d.ts" />
import React, { useCallback, useContext, useState, useEffect } from 'react'
import toast from 'react-hot-toast'
import { nameForLocale } from '@/utils/name-for-locale'
import { flagForLocale } from '@/utils/flag-for-locale'
import { GlossaryEntriesShowContext } from '.'
import { useRequestWithNextRedirect } from './useRequestWithNextRedirect'

export function Unchecked({ translation }: { translation: GlossaryEntry }) {
  const { links } = useContext(GlossaryEntriesShowContext)
  const { sendRequestWithRedirect, redirectToNext } =
    useRequestWithNextRedirect()
  const [editMode, setEditMode] = useState(false)
  const [copy, setCopy] = useState(translation.translation)
  const [textEditorValue, setTextEditorValue] = useState(
    translation.translation
  )
  const [isButtonDisabled, setIsButtonDisabled] = useState(true)

  const textAreaRef = React.useRef<HTMLTextAreaElement>(null)
  const hasBeenEdited = copy !== translation.translation

  useEffect(() => {
    const timer = setTimeout(() => {
      setIsButtonDisabled(false)
    }, 2000)

    return () => clearTimeout(timer)
  }, [])

  const updateCopy = useCallback(() => {
    if (textEditorValue !== copy) {
      setCopy(textEditorValue)
    }
    setEditMode(false)
  }, [textEditorValue, copy])

  const createProposal = useCallback(async () => {
    try {
      await sendRequestWithRedirect({
        method: 'POST',
        endpoint: links.createProposal.replace(
          'GLOSSARY_ENTRY_ID',
          translation.uuid
        ),
        body: JSON.stringify({ translation: copy }),
      })
      if (hasBeenEdited) {
        toast.success('Proposal submitted successfully!')
      } else {
        toast.success('Marked as checked successfully!')
      }
    } catch (err) {
      console.error(err)
      if (hasBeenEdited) {
        toast.error('Failed to submit proposal')
      } else {
        toast.error('Failed to mark as checked')
      }
    }
  }, [
    sendRequestWithRedirect,
    links.createProposal,
    translation.uuid,
    copy,
    hasBeenEdited,
  ])

  const cancelEditing = useCallback(() => {
    setTextEditorValue(copy)
    setEditMode(false)
  }, [copy])

  const resetChanges = useCallback(() => {
    setCopy(translation.translation)
    setTextEditorValue(translation.translation)
  }, [])

  const handleSkip = useCallback(async () => {
    try {
      await redirectToNext()
      toast.success('Entry skipped!')
    } catch (err) {
      console.error('Error skipping to next entry:', err)
      toast.error('Failed to skip entry')
    }
  }, [redirectToNext])

  const handleEdit = useCallback(() => {
    setEditMode(true)
    setTimeout(() => {
      if (textAreaRef.current) {
        textAreaRef.current.focus()
        textAreaRef.current.setSelectionRange(
          textAreaRef.current.value.length,
          textAreaRef.current.value.length
        )
      }
    }, 0)
  }, [textAreaRef])

  return (
    <div className="locale unchecked">
      <div className="header">
        <div className="text-h4">
          {nameForLocale(translation.locale)} ({translation.locale})
        </div>
        <div className="status">Needs Checking</div>

        <div className="flag">{flagForLocale(translation.locale)}</div>
      </div>
      <div className="body">
        <p className="text-16 leading-140 mb-10">
          How should we translate this word in the context of Exercism? What is
          the most natural equivalent in{' '}
          {nameForLocale(translation.locale, { displayInEnglish: true })}?
        </p>
        <div className="flex items-center gap-8 mb-12">
          <div className="text-16 w-[105px]">Original (en):</div>
          <div className="locale-value flex-grow">{translation.term}</div>
        </div>

        <div className="flex items-center gap-8 mb-12">
          <label htmlFor="translation" className="text-16 w-[105px]">
            Translation:
          </label>
          <div className="flex-grow">
            {editMode ? (
              <textarea
                ref={textAreaRef}
                id="translation"
                className="w-full p-16 block"
                rows={1}
                value={textEditorValue}
                onChange={(e) => setTextEditorValue(e.target.value)}
                name="Translation"
                aria-label="Translation"
              />
            ) : (
              <div className="locale-value">{copy}</div>
            )}
          </div>
        </div>

        {editMode ? (
          <div
            className="buttons flex gap-8"
            style={{ justifyContent: 'flex-start' }}
          >
            <button onClick={cancelEditing} className="btn-s btn-default">
              Cancel
            </button>
            <button onClick={updateCopy} className="btn-s btn-primary">
              Update Proposal
            </button>
          </div>
        ) : (
          <div className="buttons flex justify-between">
            <div className="buttons flex gap-8">
              <button onClick={handleEdit} className="btn-s btn-default">
                Edit Translation
              </button>
              {hasBeenEdited && (
                <button onClick={resetChanges} className="btn-s btn-default">
                  Reset changes
                </button>
              )}
            </div>
            <div className="buttons flex gap-8">
              <button
                onClick={() => handleSkip()}
                className="btn-s btn-default"
              >
                Skip this entry
              </button>
              <button
                onClick={createProposal}
                className="btn-s btn-primary"
                disabled={isButtonDisabled}
              >
                {hasBeenEdited ? '👍 Submit proposal' : '👍 Mark as Checked'}
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}
