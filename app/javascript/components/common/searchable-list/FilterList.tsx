import React, { useCallback } from 'react'
import { FilterValue, FilterCategory } from '../SearchableList'
import { FilterOption } from './FilterOption'

export const FilterList = ({
  value,
  setValue,
  categories,
}: {
  value: FilterValue
  setValue: (value: FilterValue) => void
  categories: FilterCategory[]
}): JSX.Element => {
  const handleChange = useCallback(
    (e, category, optionValue) => {
      if (e.target.checked) {
        setValue({ ...value, [category]: optionValue })
      } else {
        const { [category]: remove, ...rest } = value

        setValue(rest)
      }
    },
    [setValue, value]
  )

  return (
    <div className="--categories">
      {categories.map((category) => {
        const categoryValue = value[category.value]

        return (
          <div key={category.value} className="--category">
            <h4>{category.label}</h4>
            {category.options.map((option) => (
              <FilterOption
                key={option.value}
                onChange={handleChange}
                checked={categoryValue === option.value}
                label={option.label}
                value={option.value}
                category={category.value}
              />
            ))}
          </div>
        )
      })}
    </div>
  )
}
