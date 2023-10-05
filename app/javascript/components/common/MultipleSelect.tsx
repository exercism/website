import React, { useState, useCallback, useEffect } from 'react'
import { Icon, GraphicalIcon } from '.'
import { useDropdown } from '../dropdowns/useDropdown'

export const MultipleSelect = <T extends unknown>({
  value,
  options,
  setValue,
  label,
  SelectedComponent,
  OptionComponent,
  ResetComponent,
  className = '',
}: {
  value: T[]
  options: readonly T[]
  setValue: (value: T[]) => void
  label: string
  SelectedComponent: React.ComponentType<{ value: T[] }>
  OptionComponent: React.ComponentType<{ option: T }>
  ResetComponent: React.ComponentType
  className?: string
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
      placement: 'bottom-end',
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

    setChanged(true)
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
    <div className={`c-multi-select ${className}`}>
      <button {...buttonAttributes}>
        <div className="--info">
          <div className="--label">{label}</div>
          <div className="--selected-value">
            <SelectedComponent value={value} />
          </div>
        </div>
        <Icon
          icon="chevron-down"
          alt="Click to change"
          className="action-icon"
        />
      </button>
      {open ? (
        <div {...panelAttributes} className="--options">
          <ul {...listAttributes}>
            <li {...itemAttributes(0)}>
              <label className="c-checkbox-wrapper --reset">
                <input
                  type="checkbox"
                  onChange={handleReset}
                  checked={selected.length == 0}
                />
                <div className="row">
                  <div className="c-checkbox">
                    <GraphicalIcon icon="checkmark" />
                  </div>
                  <ResetComponent />
                </div>
              </label>
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
