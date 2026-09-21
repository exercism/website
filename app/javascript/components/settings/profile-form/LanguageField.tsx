// i18n-key-prefix: profileForm
// i18n-namespace: components/settings/ProfileForm.tsx
import React, { useState } from 'react'
import { Icon } from '@/components/common'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export type Language = {
  code: string
  native: string
  english: string
  flagUrl: string
}

function matchesQuery(language: Language, query: string): boolean {
  const needle = query.trim().toLocaleLowerCase()
  if (!needle) return true

  return (
    language.native.toLocaleLowerCase().includes(needle) ||
    language.english.toLocaleLowerCase().includes(needle) ||
    language.code.toLocaleLowerCase().includes(needle)
  )
}

function Flag({ language }: { language: Language }): JSX.Element {
  return <img src={language.flagUrl} alt="" aria-hidden="true" className="flag" />
}

function LanguageLabel({ language }: { language: Language }): JSX.Element {
  return (
    <React.Fragment>
      <Flag language={language} />
      <span className="names">
        <span className="native" lang={language.code}>
          {language.native}
        </span>
        <span className="english">{language.english}</span>
      </span>
    </React.Fragment>
  )
}

export function LanguageField({
  languages,
  comingSoonLanguages,
  locale,
  saving,
  onSelect,
}: {
  languages: Language[]
  comingSoonLanguages: Language[]
  locale: string
  saving: boolean
  onSelect: (locale: string) => void
}): JSX.Element {
  const { t } = useAppTranslation('components/settings/ProfileForm.tsx')
  const [editing, setEditing] = useState(false)
  const [query, setQuery] = useState('')

  const current =
    languages.find((language) => language.code === locale) || languages[0]
  const live = languages.filter((language) => matchesQuery(language, query))
  const comingSoon = comingSoonLanguages.filter((language) =>
    matchesQuery(language, query)
  )

  const close = () => {
    setEditing(false)
    setQuery('')
  }

  const select = (code: string) => {
    if (code === locale) {
      close()
      return
    }

    onSelect(code)
  }

  return (
    <div className="c-language-field">
      <div className="current">
        <Flag language={current} />
        <span className="native" lang={current.code}>
          {current.native}
        </span>
        <span className="english">({current.english})</span>
        <button
          type="button"
          className="btn-secondary btn-xs"
          disabled={saving}
          aria-expanded={editing}
          onClick={() => (editing ? close() : setEditing(true))}
        >
          {editing ? t('profileForm.languageDone') : t('profileForm.languageEdit')}
        </button>
      </div>

      {editing ? (
        <div
          className="picker"
          onKeyDown={(e) => {
            if (e.key === 'Escape') close()
          }}
        >
          <div className="search-row">
            <Icon icon="search" alt="" className="search-icon" />
            <input
              type="search"
              className="search"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder={t('profileForm.languageSearchPlaceholder')}
              aria-label={t('profileForm.languageSearchLabel')}
              autoComplete="off"
            />
          </div>

          <div className="scroll">
            {live.length > 0 ? (
              <ul className="group">
                {live.map((language) => (
                  <li key={language.code}>
                    <button
                      type="button"
                      className="option"
                      aria-current={language.code === locale ? 'true' : undefined}
                      disabled={saving}
                      onClick={() => select(language.code)}
                    >
                      <LanguageLabel language={language} />
                      {language.code === locale ? (
                        <Icon
                          icon="checkmark"
                          alt={t('profileForm.languageSelected')}
                          className="check"
                        />
                      ) : null}
                    </button>
                  </li>
                ))}
              </ul>
            ) : null}

            {comingSoon.length > 0 ? (
              <React.Fragment>
                <p className="group-heading">
                  {t('profileForm.languageComingSoon')}
                </p>
                <ul className="group">
                  {comingSoon.map((language) => (
                    <li key={language.code}>
                      <span className="option --disabled">
                        <LanguageLabel language={language} />
                        <span className="badge">
                          {t('profileForm.languageComingSoonBadge')}
                        </span>
                      </span>
                    </li>
                  ))}
                </ul>
              </React.Fragment>
            ) : null}

            {live.length === 0 && comingSoon.length === 0 ? (
              <p className="empty">{t('profileForm.languageNoMatches')}</p>
            ) : null}
          </div>
        </div>
      ) : null}
    </div>
  )
}
