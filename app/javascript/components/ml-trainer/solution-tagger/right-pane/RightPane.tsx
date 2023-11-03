import React, { useState } from 'react'
import { PlaceholderStuff } from './PlaceholderStuff'
import { TagSelector } from './TagSelector'
import {
  SolutionTaggerConfirmTagsAPIResponse,
  SolutionTaggerProps,
  Tags,
} from '../SolutionTagger.types'
import { useMutation } from 'react-query'
import { redirectTo, typecheck } from '@/utils'
import { sendRequest } from '@/utils/send-request'

export function RightPane({
  tags,
  links,
}: Pick<SolutionTaggerProps, 'tags' | 'links'>): JSX.Element {
  const [selectedTags, setSelectedTags] = useState<Tags>([])
  const [confirmTags] = useMutation<SolutionTaggerConfirmTagsAPIResponse>(
    async () => {
      const { fetch } = sendRequest({
        endpoint: links.confirmTagsEndpoint,
        method: 'POST',
        body: JSON.stringify({ tags: selectedTags }),
      })

      return fetch
    },
    {
      onSuccess: (data) => {
        redirectTo(data.nextExerciseLink)
      },
    }
  )

  return (
    <div className="px-24 h-100 flex flex-col">
      <PlaceholderStuff />
      <TagSelector tags={tags} setSelectedTags={setSelectedTags} />
      <button
        onClick={() => confirmTags()}
        className="btn-m btn-primary mt-auto mb-64"
      >
        Save, next!
      </button>
    </div>
  )
}
