import React, { useCallback } from 'react'
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

export function LocaleSelect({
  locales,
  value,
  onChange,
  showAll = true,
  label = 'Open the locale filter',
}: {
  locales: string[]
  value: string
  onChange: (locale: string) => void
  showAll?: boolean
  label?: string
}) {
  const availableLocales = locales
  const selectedLocale = value
  const handleLocaleChange = onChange

  const dropdownLength = showAll
    ? availableLocales.length + 1
    : availableLocales.length

  const {
    buttonAttributes,
    panelAttributes,
    listAttributes,
    itemAttributes,
    setOpen,
    open,
  } = useDropdown(dropdownLength, (i) => handleItemSelect(i), {
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
      if (showAll && index === 0) {
        handleLocaleChange('')
      } else {
        const localeIndex = showAll ? index - 1 : index
        const locale = availableLocales[localeIndex]
        if (locale) {
          handleLocaleChange(locale)
        }
      }
      setOpen(false)
    },
    [availableLocales, setOpen, handleLocaleChange, showAll]
  )

  if (!availableLocales || availableLocales.length === 0) {
    return null
  }

  return (
    <div className={`c-single-select c-track-select --size-automation`}>
      <button
        className="current-track gap-8"
        style={{ minWidth: '200px' }}
        aria-label={label}
        {...buttonAttributes}
      >
        <div className="track-title">
          {selectedLocale
            ? nameForLocale(selectedLocale)
            : showAll
            ? 'All'
            : 'Select locale'}
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
            {showAll && (
              <li key="all" {...itemAttributes(0)}>
                <label className="c-radio-wrapper">
                  <input
                    type="radio"
                    onChange={() => {
                      handleLocaleChange('')
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
            )}
            {availableLocales.map((locale, i) => {
              const itemIndex = showAll ? i + 1 : i
              return (
                <li key={locale} {...itemAttributes(itemIndex)}>
                  <LocaleOption
                    locale={locale}
                    onChange={() => {
                      handleLocaleChange(locale)
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
