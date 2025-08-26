import React, { useEffect, useState } from 'react'
import Modal from './Modal'
import { useLogger } from '@/hooks'

type Props = {
  supportedLocales: string[]
}

const STORAGE_KEY = 'external-locale'

const normalizeLocale = (locale: string): string =>
  locale.toLowerCase().replace('_', '-')

const getCurrentLocaleFromPath = (): string | null => {
  const pathSegment = window.location.pathname.split('/')[1]
  return pathSegment ? normalizeLocale(pathSegment) : null
}

const buildNewUrl = (locale: string): string => {
  const parts = window.location.pathname.split('/')
  parts[1] = locale
  const newPath = parts.join('/') || `/${locale}`
  return `${newPath}${window.location.search}${window.location.hash}`
}

const findBestMatch = (
  targetLocale: string,
  supportedLocales: string[]
): string | null => {
  const normalized = normalizeLocale(targetLocale)
  const normalizedSupported = supportedLocales.map(normalizeLocale)

  // Exact match
  if (normalizedSupported.includes(normalized)) {
    return normalized
  }

  // Language code match (e.g., 'en' matches 'en-us')
  const languageCode = normalized.split('-')[0]
  const languageVariant = normalizedSupported.find(
    (locale) => locale.split('-')[0] === languageCode
  )

  return languageVariant || null
}

const getUserPreferredLocale = (supportedLocales: string[]): string | null => {
  // Check stored preference first
  const stored = localStorage.getItem(STORAGE_KEY)
  if (stored) {
    return findBestMatch(stored, supportedLocales)
  }

  // Check browser languages
  const browserLocales = [
    ...(navigator.languages || []),
    navigator.language,
  ].filter(Boolean)

  for (const locale of browserLocales) {
    const match = findBestMatch(locale, supportedLocales)
    if (match) return match
  }

  return null
}

export default function ExternalLanguageSelectorModal({
  supportedLocales,
}: Props) {
  const [preferredLocale, setPreferredLocale] = useState<string | null>(null)
  const [isOpen, setIsOpen] = useState(false)

  useLogger('supportedLocales in ExternalLanguageSelectorModal', {
    supportedLocales,
  })

  useEffect(() => {
    const currentLocale = getCurrentLocaleFromPath()
    if (!currentLocale) return

    const preferred = getUserPreferredLocale(supportedLocales)
    if (!preferred) return

    // Don't show modal if preferred locale matches current locale
    if (
      preferred === currentLocale ||
      preferred.split('-')[0] === currentLocale.split('-')[0]
    ) {
      return
    }

    setPreferredLocale(preferred)
    setIsOpen(true)
  }, [supportedLocales])

  const handleAccept = () => {
    if (!preferredLocale) return
    localStorage.setItem(STORAGE_KEY, preferredLocale)
    window.location.assign(buildNewUrl(preferredLocale))
  }

  const handleDecline = () => {
    const currentLocale = getCurrentLocaleFromPath()
    if (currentLocale) {
      localStorage.setItem(STORAGE_KEY, currentLocale)
    }
    setIsOpen(false)
  }

  if (!isOpen || !preferredLocale) {
    return null
  }

  // Use copy based on preferred locale; fallback to English
  const copy =
    EXTERNAL_LANGUAGE_COPY[preferredLocale] ?? EXTERNAL_LANGUAGE_COPY.en

  return (
    <Modal open={isOpen} onClose={handleDecline}>
      <div className="flex flex-col gap-4 p-4 max-w-md">
        <h1 className="text-h3 font-semibold mb-12">{copy.question}</h1>

        <div className="flex gap-4 items-center">
          <button className="btn btn-primary" onClick={handleAccept}>
            {copy.accept}
          </button>
          <button className="btn btn-default" onClick={handleDecline}>
            {copy.decline}
          </button>
        </div>
      </div>
    </Modal>
  )
}

type Copy = {
  question: string
  accept: string
  decline: string
}

export const EXTERNAL_LANGUAGE_COPY: Record<string, Copy> = {
  en: {
    question: '🏴󠁧󠁢󠁥󠁮󠁧󠁿 Would you rather use Exercism in English?',
    accept: 'Switch to English',
    decline: 'No, thanks',
  },
  hu: {
    question: '🇭🇺 Szeretnéd az Exercismet magyarul használni?',
    accept: 'Váltás magyar nyelvre',
    decline: 'Nem, köszönöm',
  },
  nl: {
    question: '🇳🇱 Wil je Exercism liever in het Nederlands gebruiken?',
    accept: 'Overschakelen naar Nederlands',
    decline: 'Nee, bedankt',
  },
  de: {
    question: '🇩🇪 Möchtest du Exercism lieber auf Deutsch verwenden?',
    accept: 'Zu Deutsch wechseln',
    decline: 'Nein, danke',
  },
  pt: {
    question: '🇵🇹 Gostarias de usar o Exercism em português?',
    accept: 'Mudar para português',
    decline: 'Não, obrigado',
  },
  'pt-br': {
    question: '🇧🇷 Gostaria de usar o Exercism em português do Brasil?',
    accept: 'Mudar para português do Brasil',
    decline: 'Não, obrigado',
  },
}
