import React, { useRef, useState } from 'react'
import { GraphicalIcon } from './GraphicalIcon'

type SearchInputProps = {
  filter: string | undefined
  setFilter: (filter: string) => void
  placeholder: string
}

const WRAPPER_CLASSNAMES =
  'bg-unnamed15 text-textColor6 flex flex-row rounded-[5px] border-1 border-transparent py-[11px] px-[21px] text-16 w-[420px] focus-within:focused-input hover:cursor-text'

const INPUT_CLASSNAMES = 'border-none bg-inherit !w-[100%] portable-input'
const ICON_CLASSNAMES = 'w-[24px] h-[24px] my-auto mr-[16px] textColor6-filter'

export default function SearchInput({
  filter,
  setFilter,
  placeholder,
}: SearchInputProps): JSX.Element {
  const searchInputRef = useRef<HTMLInputElement>(null)
  const [focused, setFocused] = useState<boolean>(false)

  const focusInputElement = () => {
    searchInputRef.current?.focus()
  }

  return (
    <div className={WRAPPER_CLASSNAMES} onClick={focusInputElement}>
      <GraphicalIcon
        className={ICON_CLASSNAMES + (focused ? 'filter-none' : '')}
        icon="search"
      />
      <input
        onFocus={() => setFocused(true)}
        onBlur={() => setFocused(false)}
        ref={searchInputRef}
        type="text"
        className={INPUT_CLASSNAMES}
        style={{ all: 'unset' }}
        value={filter}
        onChange={(e) => setFilter(e.target.value)}
        placeholder={placeholder}
      />
    </div>
  )
}
