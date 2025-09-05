import { SearchInput } from '@/components/common'
import { useDebounce } from '@uidotdev/usehooks'
import React, { useEffect } from 'react'
import { OriginalsListContext } from '.'
import { OriginalsTableList } from './OriginalsTableList'
import { Tabs } from './Tabs'

export function Table() {
  const { setCriteria, request } = React.useContext(OriginalsListContext)

  const [inputValue, setInputValue] = React.useState(
    request.query.criteria || ''
  )
  const debouncedValue = useDebounce(inputValue, 300)

  useEffect(() => {
    setCriteria(debouncedValue)
  }, [debouncedValue, setCriteria])

  return (
    <div className="originals-table">
      <Tabs />
      <div className="container">
        <header className="c-search-bar">
          <SearchInput
            setFilter={setInputValue}
            filter={inputValue}
            placeholder="Search for translation"
          />
        </header>
        <OriginalsTableList />
      </div>
    </div>
  )
}
