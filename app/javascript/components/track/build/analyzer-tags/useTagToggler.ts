import { useCallback } from 'react'
import { sendRequest } from '@/utils/send-request'
import { useMutation } from '@tanstack/react-query'
import { AnalyzerTagsEndpoints, Tag, TagFlags } from './AnalyzerTags.types'
import { debounce } from '@/utils/debounce'

export function useTagToggler({
  setLocalTags,
  endpoints,
}: {
  setLocalTags: React.Dispatch<React.SetStateAction<Tag[]>>
  endpoints: AnalyzerTagsEndpoints
}) {
  const { mutate } = useMutation(
    ({ tag, field }: { tag: Tag; field: TagFlags }) => {
      const endpoint = endpoints[field].replace(
        ':tag',
        encodeURIComponent(tag.tag)
      )
      const { fetch } = sendRequest({
        endpoint,
        method: tag[field] ? 'DELETE' : 'POST',
        body: null,
      })

      return fetch
    }
  )

  const debouncedMutate = debounce(mutate, 300)

  const handleToggle = useCallback((tag: Tag, field: TagFlags) => {
    setLocalTags((tags) =>
      tags.map((t) => {
        if (t.tag === tag.tag) {
          return { ...t, [field]: !t[field] }
        }
        return t
      })
    )

    debouncedMutate({ tag, field })
  }, [])

  return { handleToggle }
}
