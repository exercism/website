// i18n-namespace: components/common/SingleSelect.tsx
import React, { useCallback } from 'react'
import { Icon } from './Icon'
import { useDropdown } from '../dropdowns/useDropdown'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const SingleSelect = <T extends unknown>({
  options,
  value,
  setValue,
  SelectedComponent,
  OptionComponent,
  className = '',
  disabled = false,
}: {
  value: T
  options: readonly T[]
  setValue: (value: T) => void
  SelectedComponent: React.ComponentType<{ option: T }>
  OptionComponent: React.ComponentType<{ option: T }>
  className?: string
  disabled?: boolean
}): JSX.Element => {
  const { t } = useAppTranslation('components/common/SingleSelect.tsx')
  const {
    buttonAttributes,
    panelAttributes,
    listAttributes,
    itemAttributes,
    setOpen,
    open,
  } = useDropdown(
    options.length,
    (i) => {
      handleItemSelect(i)
    },
    {
      placement: 'bottom-start',
      modifiers: [
        {
          name: 'offset',
          options: {
            offset: [0, 8],
          },
        },
      ],
    }
  )
  const handleChange = useCallback(
    (option: T) => {
      setValue(option)
      setOpen(false)
    },
    [setOpen, setValue]
  )
  const handleItemSelect = useCallback(
    (index) => {
      handleChange(options[index])
    },
    [handleChange, options]
  )

  const classNames = ['c-single-select', className].filter(
    (className) => className.length > 0
  )

  return (
    <div className={classNames.join(' ')}>
      <button disabled={disabled} type="button" {...buttonAttributes}>
        <div className="value">
          <SelectedComponent option={value} />
        </div>
        <Icon
          icon="chevron-down"
          alt={t('singleSelect.clickToChange')}
          className="action-icon"
        />
      </button>
      {open ? (
        <div {...panelAttributes} className="--options">
          <ul {...listAttributes}>
            {options.map((option, i) => {
              return (
                <li key={i} {...itemAttributes(i)}>
                  <label className="c-radio-wrapper">
                    <input
                      type="radio"
                      onChange={() => handleChange(option)}
                      checked={option === value}
                    />
                    <div className="row">
                      <OptionComponent option={option} />
                    </div>
                  </label>
                </li>
              )
            })}
          </ul>
        </div>
      ) : null}
    </div>
  )
}
