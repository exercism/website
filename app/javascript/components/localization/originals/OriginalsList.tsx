import { SearchInput } from '@/components/common/SearchInput'
import { assembleClassNames } from '@/utils/assemble-classnames'
import React, { useState } from 'react'

export default function OriginalsList() {
  return (
    <div>
      <Tabs />
      <Table />
    </div>
  )
}

const TABS = [
  {
    value: 'unchecked',
    label: 'Needs translating',
  },
  { value: 'propsed', label: 'Needs reviewing' },
  { value: 'checked', label: 'Done' },
]
export function Tabs() {
  const [selectedTab, setSelectedTab] = React.useState('unchecked')
  return (
    <div className="flex items-center tabs">
      {TABS.map((tab) => (
        <button
          className={assembleClassNames(
            'c-tab h-32',
            selectedTab === tab.value && 'selected'
          )}
          onClick={() => setSelectedTab(tab.value)}
        >
          {tab.label}
        </button>
      ))}
    </div>
  )
}

export function Table() {
  const [criteria, setCriteria] = useState<string | undefined>(undefined)
  return (
    <div className="c-mentor-automation">
      <div className="container">
        <header className="c-search-bar automation-header">
          <SearchInput
            setFilter={(input) => {
              setCriteria(input)
            }}
            filter={criteria || ''}
            placeholder="Search for translation"
          />
        </header>
      </div>
    </div>
  )
}
