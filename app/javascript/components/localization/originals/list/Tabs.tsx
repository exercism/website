import { assembleClassNames } from '@/utils/assemble-classnames'
import React from 'react'
import { OriginalsListContext } from '.'

const TABS = [
  { value: undefined, label: 'All' },
  { value: 'unchecked', label: 'Needs translating' },
  { value: 'proposed', label: 'Needs reviewing' },
  { value: 'checked', label: 'Done' },
]

export function Tabs() {
  const { request, setQuery } = React.useContext(OriginalsListContext)
  return (
    <div className="flex items-center tabs mb-16">
      {TABS.map((tab) => (
        <button
          key={tab.label}
          className={assembleClassNames(
            'c-tab',
            request.query.status === tab.value && 'selected'
          )}
          onClick={() => setQuery({ ...request.query, status: tab.value })}
        >
          {tab.label}
        </button>
      ))}
    </div>
  )
}
