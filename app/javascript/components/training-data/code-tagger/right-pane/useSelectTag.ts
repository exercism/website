import { useState } from 'react'
import { useMutation } from '@tanstack/react-query'
import { redirectTo } from '@/utils'
import { sendRequest } from '@/utils/send-request'
import {
  Tags,
  CodeTaggerConfirmTagsAPIResponse,
  CodeTaggerProps,
} from '../CodeTagger.types'

export function useSelectTag({
  links,
  defaultSelectedTags,
}: Pick<CodeTaggerProps, 'links'> & { defaultSelectedTags: Tags }) {
  const [selectedTags, setSelectedTags] = useState<Tags>(defaultSelectedTags)

  const { mutate: confirmTags } = useMutation<CodeTaggerConfirmTagsAPIResponse>(
    () => {
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
