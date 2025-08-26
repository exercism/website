import React, { useEffect, useState } from 'react'
import Modal from '../Modal'
import {
  detectLocaleFromPath,
  getUserPreferredLocale,
  buildNewUrl,
  buildLocaleChoices,
  normalizeLocale,
} from './utils'
import { EXTERNAL_LANGUAGE_COPY } from './copy'

type Props = {
  supportedLocales: string[]
}

const STORAGE_KEY = 'external-locale'

export default function ExternalLanguageSelectorModal({
  supportedLocales,
}: Props) {
  const [isOpen, setIsOpen] = useState(false)
  const [choices, setChoices] = useState<string[]>([])

  useEffect(() => {
    const { locale: currentLocale, hasLocaleInPath } =
      detectLocaleFromPath(supportedLocales)
    const preferred = getUserPreferredLocale(supportedLocales, STORAGE_KEY)

    const ordered = buildLocaleChoices({
      supportedLocales,
      currentLocale,
      preferredLocale: preferred,
      fallbackLocale: 'en',
    })

    const shouldOpen =
      !hasLocaleInPath ||
      (!!currentLocale &&
        !!preferred &&
        currentLocale.split('-')[0] !== preferred.split('-')[0])

    if (shouldOpen && ordered.length > 0) {
      setChoices(ordered)
      setIsOpen(true)
    }
  }, [supportedLocales])

  const handleChoose = (locale: string) => {
    const loc = normalizeLocale(locale)
    localStorage.setItem(STORAGE_KEY, loc)
    window.location.assign(buildNewUrl(loc, supportedLocales))
  }

  const handleClose = () => setIsOpen(false)

  if (!isOpen || choices.length === 0) return null

  return (
    <Modal
      open={isOpen}
      onClose={handleClose}
      shouldCloseOnOverlayClick={false}
      shouldCloseOnEsc={false}
    >
      <div className="flex flex-col gap-6 p-4 max-w-md">
        <div className="space-y-2">
          {choices.map((loc) => {
            const key = normalizeLocale(loc)
            const copy =
              EXTERNAL_LANGUAGE_COPY[key] ?? EXTERNAL_LANGUAGE_COPY.en
            return (
              <h2 key={`q-${key}`} className="text-h4 font-semibold">
                {copy.question}
              </h2>
            )
          })}
        </div>

        <div className="flex flex-wrap gap-4 items-center">
          {choices.map((loc) => {
            const key = normalizeLocale(loc)
            const copy =
              EXTERNAL_LANGUAGE_COPY[key] ?? EXTERNAL_LANGUAGE_COPY.en
            return (
              <button
                key={`btn-${key}`}
                className="btn btn-default"
                onClick={() => handleChoose(key)}
              >
                {copy.choice}
              </button>
            )
          })}
        </div>
      </div>
    </Modal>
  )
}
