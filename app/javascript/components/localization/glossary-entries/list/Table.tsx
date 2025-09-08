import { SearchInput } from '@/components/common'
import { useDebounce } from '@uidotdev/usehooks'
import React, { useEffect } from 'react'
import { GlossaryEntriesListContext } from '.'
import { GlossaryEntriesTableList } from './GlossaryEntriesTableList'
import { Tabs } from './Tabs'

export function Table() {
  const { setCriteria, request } = React.useContext(GlossaryEntriesListContext)

  const [inputValue, setInputValue] = React.useState(
    request.query.criteria || ''
  )
  const debouncedValue = useDebounce(inputValue, 300)

  useEffect(() => {
    setCriteria(debouncedValue)
  }, [debouncedValue, setCriteria])

  return (
    <div className="originals-table">
      <div className="flex items-center justify-between mb-16">
        <Tabs />
        <AddTermButton />
      </div>

      <div className="container">
        <header className="c-search-bar">
          <SearchInput
            setFilter={setInputValue}
            filter={inputValue}
            placeholder="Search for translation"
          />
        </header>
        <GlossaryEntriesTableList />
      </div>
    </div>
  )
}

function AddTermButton({}) {
  return <button className="btn btn-primary btn-m">+ Add Term</button>
}
