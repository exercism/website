import React, { useCallback } from 'react'
import { Icon } from '.'
import { useDropdown } from '../dropdowns/useDropdown'

export const ExercismSelect = <T extends unknown>({
  options,
  value,
  setValue,
  SelectedComponent,
  OptionComponent,
  componentClassName = '',
  buttonClassName = '',
  panelClassName = '',
}: {
  value: T
  options: readonly T[]
  setValue: (value: T) => void
  SelectedComponent: React.ComponentType<{ value: T }>
  OptionComponent: React.ComponentType<{
    onChange: () => void
    checked: boolean
    option: T
  }>
  componentClassName?: string
  buttonClassName?: string
  panelClassName?: string
}): JSX.Element => {
  const handleItemSelect = useCallback(
    (index) => {
      setValue(options[index])
    },
    [setValue, options]
  )
  const {
    buttonAttributes,
    panelAttributes,
    listAttributes,
    itemAttributes,
    setOpen,
    open,
  } = useDropdown(options.length, handleItemSelect, {
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

  return (
    <div className={componentClassName}>
      <button className={buttonClassName} {...buttonAttributes}>
        <SelectedComponent value={value} />
        <Icon
          icon="chevron-down"
          alt="Click to change"
          className="action-icon"
        />
      </button>
      {open ? (
        <div {...panelAttributes} className={panelClassName}>
          <ul {...listAttributes}>
            {options.map((option, i) => {
              return (
                <li key={i} {...itemAttributes(i)}>
                  <OptionComponent
                    onChange={() => {
                      setValue(option)
                      setOpen(false)
                    }}
                    checked={option === value}
                    option={option}
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
