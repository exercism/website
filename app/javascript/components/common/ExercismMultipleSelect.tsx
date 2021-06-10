import React, { useState, useCallback, useEffect } from 'react'
import { Icon, GraphicalIcon } from '.'
import { useDropdown } from '../dropdowns/useDropdown'

export const ExercismMultipleSelect = <T extends unknown>({
  options,
  value,
  setValue,
  SelectedComponent,
  OptionComponent,
  ResetComponent,
  componentClassName = '',
  buttonClassName = '',
  panelClassName = '',
}: {
  value: T[]
  options: readonly T[]
  setValue: (value: T[]) => void
  SelectedComponent: React.ComponentType<{ value: T[] }>
  OptionComponent: React.ComponentType<{ option: T }>
  ResetComponent: React.ComponentType
  componentClassName?: string
  buttonClassName?: string
  panelClassName?: string
}): JSX.Element => {
  const [selected, setSelected] = useState<T[]>(value)
  const [changed, setChanged] = useState(false)
  const {
    buttonAttributes,
    panelAttributes,
    listAttributes,
    itemAttributes,
    open,
  } = useDropdown(
    options.length + 1,
    (i) => {
      handleItemSelect(i)
    },
    {
      placement: 'bottom',
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
      if (selected.includes(option)) {
        setSelected(selected.filter((v) => v !== option))
      } else {
        setSelected([...selected, option])
      }

      setChanged(true)
    },
    [setSelected, selected]
  )
  const handleReset = useCallback(() => {
    setSelected([])
  }, [])
  const handleItemSelect = useCallback(
    (index) => {
      if (index === 0) {
        return handleReset()
      }

      handleChange(options[index - 1])
    },
    [handleChange, handleReset, options]
  )

  useEffect(() => {
    setSelected(value)
  }, [value])

  useEffect(() => {
    if (open || !changed) {
      return
    }

    setValue(selected)
    setChanged(false)
  }, [changed, open, selected, setValue])

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
            <li {...itemAttributes(0)}>
              <button type="button" onClick={handleReset}>
                <ResetComponent />
              </button>
            </li>
            {options.map((option, i) => {
              return (
                <li key={i + 1} {...itemAttributes(i + 1)}>
                  <label className="c-checkbox-wrapper">
                    <input
                      type="checkbox"
                      onChange={() => handleChange(option)}
                      checked={selected.includes(option)}
                    />
                    <div className="row">
                      <div className="c-checkbox">
                        <GraphicalIcon icon="checkmark" />
                      </div>
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
