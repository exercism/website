import React, { useCallback, useContext, useState } from 'react'
import { GlossaryEntriesListContext } from '.'
import { flagForLocale } from '@/utils/flag-for-locale'
import { useDropdown } from '../../../dropdowns/useDropdown'
import { Icon } from '../../../common'
import { nameForLocale } from '@/utils/name-for-locale'

const LocaleOption = ({
  locale,
  checked,
  onChange,
}: {
  locale: string
  checked: boolean
  onChange: (e: React.ChangeEvent) => void
}): JSX.Element => {
  return (
    <label className="c-radio-wrapper">
      <input
        type="radio"
        onChange={onChange}
        checked={checked}
        name="locale_filter"
      />
      <div className="row gap-8">
        <div className="title">{nameForLocale(locale)}</div>
        <span className="flag">{flagForLocale(locale)}</span>
      </div>
    </label>
  )
}

export function LocaleSelect() {
  // ["hu", "de"] etc
  const { translationLocales } = useContext(GlossaryEntriesListContext)
  const [selectedLocale, setSelectedLocale] = useState<string>('')

  const {
    buttonAttributes,
    panelAttributes,
    listAttributes,
    itemAttributes,
    setOpen,
    open,
  } = useDropdown(translationLocales.length + 1, (i) => handleItemSelect(i), {
    placement: 'bottom',
    modifiers: [
      {
        name: 'offset',
        options: {
          offset: [0, 8],
        },
      },
    ],
  })

  const handleItemSelect = useCallback(
    (index: number) => {
      if (index === 0) {
        setSelectedLocale('')
      } else {
        const locale = translationLocales[index - 1]
        if (locale) {
          setSelectedLocale(locale)
        }
      }
      setOpen(false)
    },
    [translationLocales, setOpen]
  )

  if (!translationLocales || translationLocales.length === 0) {
    return null
  }

  return (
    <div className={`c-single-select c-track-select --size-automation`}>
      <button
        className="current-track gap-8"
        style={{ minWidth: '200px' }}
        aria-label="Open the locale filter"
        {...buttonAttributes}
      >
        <div className="track-title">
          {selectedLocale ? nameForLocale(selectedLocale) : 'All'}
        </div>
        {selectedLocale && (
          <span className="flag">{flagForLocale(selectedLocale)}</span>
        )}
        <Icon
          icon="chevron-down"
          alt="Click to change locale"
          className="action-icon"
        />
      </button>
      {open ? (
        <div {...panelAttributes} className="--options">
          <ul {...listAttributes}>
            <li key="all" {...itemAttributes(0)}>
              <label className="c-radio-wrapper">
                <input
                  type="radio"
                  onChange={() => {
                    setSelectedLocale('')
                    setOpen(false)
                  }}
                  checked={selectedLocale === ''}
                  name="locale_filter"
                />
                <div className="row gap-8">
                  <div className="title">All</div>
                </div>
              </label>
            </li>
            {translationLocales.map((locale, i) => {
              return (
                <li key={locale} {...itemAttributes(i + 1)}>
                  <LocaleOption
                    locale={locale}
                    onChange={() => {
                      setSelectedLocale(locale)
                      setOpen(false)
                    }}
                    checked={selectedLocale === locale}
                  />
                </li>
              )
            })}
          </ul>
        </div>
      ) : null}
    </div>
  )
}
