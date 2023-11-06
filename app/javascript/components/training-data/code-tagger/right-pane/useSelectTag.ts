import { useState } from 'react'
import { useMutation } from 'react-query'
import { redirectTo } from '@/utils'
import { sendRequest } from '@/utils/send-request'
import {
  Tags,
  CodeTaggerConfirmTagsAPIResponse,
  CodeTaggerProps,
} from '../CodeTagger.types'

export function useSelectTag({ links }: Pick<CodeTaggerProps, 'links'>) {
  const [selectedTags, setSelectedTags] = useState<Tags>([])

  const [confirmTags] = useMutation<CodeTaggerConfirmTagsAPIResponse>(
    async () => {
      const { fetch } = sendRequest({
        endpoint: links.confirmTagsApi,
        method: 'POST',
        body: JSON.stringify({ tags: selectedTags }),
      })

      return fetch
    },
    {
      onSuccess: () => {
        redirectTo(links.nextTaggableCodeLink)
      },
    }
  )

  return { confirmTags, setSelectedTags }
}
