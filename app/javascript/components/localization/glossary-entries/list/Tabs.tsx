import { assembleClassNames } from '@/utils/assemble-classnames'
import React from 'react'
import { GlossaryEntriesListContext } from '.'

const TABS = [
  { value: undefined, label: 'All' },
  { value: 'unchecked', label: 'Needs translating' },
  { value: 'proposed', label: 'Needs reviewing' },
  { value: 'checked', label: 'Done' },
]

export function Tabs() {
  const { request, setQuery } = React.useContext(GlossaryEntriesListContext)
  return (
    <div className="flex items-center tabs mb-0">
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
