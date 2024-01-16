import { useState, useCallback, useEffect } from 'react'
import { TagArray } from './ExerciseTagFilter.types'
import { Request } from '@/hooks/request-query'

export function useExerciseTagFilter({
  setQuery,
  request,
}: {
  request: Request
  setQuery: (query: any) => void
}) {
  const [tagState, setTagState] = useState<TagArray>([])
  const handleToggleTag = useCallback(
    (tagName: string, isChecked: boolean) => {
      let newState: string[]
      if (isChecked) {
        newState = [...tagState, tagName]
      } else {
        newState = tagState.filter((tag) => tag !== tagName)
      }

      setTagState(newState)
      setQuery({
        ...request.query,
        tags: newState,
      })
    },
    [tagState, setQuery]
  )

  useEffect(() => {
    const params = new URLSearchParams(window.location.search)

    const tags = params.getAll('tags[]')

    if (tags.length > 0) {
      setQuery({ ...request.query, tags: tags })
      setTagState(tags)
    }
  }, [])

  return { tagState, handleToggleTag }
}
