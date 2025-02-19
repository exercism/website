import React, { useState } from 'react'
import { wrapWithErrorBoundary } from '@/components/bootcamp/common/ErrorBoundary/wrapWithErrorBoundary'
import { assembleClassNames } from '@/utils/assemble-classnames'

import { GraphicalIcon } from '@/components/common/GraphicalIcon'
import CreatableSelect from 'react-select/creatable'

export type StudentCodeGetter = () => string | undefined

function _Header({
  links,
  handleSaveChanges,
  someTestsAreFailing,
}: {
  links: Record<any, any>
  handleSaveChanges: () => void
  someTestsAreFailing: boolean
}) {
  const [value, setValue] = useState<{ label: string; value: string }[]>([])

  return (
    <div className="page-header justify-between">
      <div className="ident">
        <GraphicalIcon icon="logo" category="bootcamp" />
        <div>
          <strong className="font-semibold">Exercism</strong> Bootcamp
        </div>
      </div>

      <div className="flex items-center gap-8">
        <CustomFnMultiSelect value={value} setValue={setValue} />
        <button
          className="btn-primary btn-xxs"
          disabled={someTestsAreFailing}
          onClick={handleSaveChanges}
        >
          Save
        </button>

        <a
          href={links.customFunctionsIndex}
          className={assembleClassNames('btn-secondary btn-xxs')}
        >
          Back to my stdlib
        </a>
      </div>
    </div>
  )
}

export const Header = wrapWithErrorBoundary(_Header)

function CustomFnMultiSelect({ value, setValue }) {
  return (
    <CreatableSelect
      isMulti
      // ref={selectRef}
      defaultValue={[{ label: 'len', value: 'my#len' }]}
      value={value}
      options={[
        { label: 'len', value: 'my#len' },
        { label: 'index_of', value: 'my#index_of' },
      ]}
      isClearable={false}
      maxMenuHeight={100}
      styles={{
        valueContainer: (base) => ({
          ...base,
          minWidth: '120px',
          padding: '4px',
        }),

        indicatorSeparator: (base) => ({
          ...base,
          display: 'none',
          '&:focus': {
            border: 'none',
            outline: 'none',
          },
        }),
        indicatorsContainer: (base) => ({
          ...base,
          display: 'none',
          border: 'none',
          '&:focus': {
            border: 'none',
            outline: 'none',
          },
        }),

        multiValue: (base) => ({
          ...base,
          borderRadius: '4px',
          overflow: 'hidden',
          backgroundColor: 'var(--backgroundColorI)',
          border: '1px solid',
          borderColor: '#2E57E8',
          margin: '2px',
        }),
        multiValueLabel: (base) => ({
          ...base,
          fontSize: '14px',
          padding: '2px',
          paddingLeft: '4px',
        }),
        multiValueRemove: (base) => ({
          ...base,
          paddingRight: '4px',
          color: 'var(--textColor6)',
          '&:hover': {
            background: '#E27979',
            color: 'var(--textColor1)',
          },
        }),
      }}
      onChange={(selected): void => {
        setValue(selected as { label: string; value: string }[])
      }}
    />
  )
}
