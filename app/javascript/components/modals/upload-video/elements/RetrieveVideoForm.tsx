import React, { useCallback, useContext, useState } from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { DigDeeperDataContext } from '@/components/track/DigDeeper'
import type { CommunityVideoType } from '@/components/types'
import { UploadVideoTextInput } from '.'

export type VideoDataResponse =
  | { communityVideo: CommunityVideoType }
  | undefined
  | null

type RetrieveVideoForm = {
  onSuccess: (data: VideoDataResponse) => void
}

export function RetrieveVideoForm({
  onSuccess,
}: RetrieveVideoForm): JSX.Element {
  const { links } = useContext(DigDeeperDataContext)
  async function VerifyVideo(link: string) {
    const URL = `${links.video.lookup}?video_url=${link}`
    const { fetch } = sendRequest({ endpoint: URL, body: null, method: 'GET' })
    return fetch
  }

  const [retrievalError, setRetrievalError] = useState(false)

  const { mutate: verifyVideo } = useMutation(
    async (url: any) => VerifyVideo(url),
    {
      onSuccess: (data: VideoDataResponse) => onSuccess(data),
      onError: () => setRetrievalError(true),
    }
  )

  const handleRetrieveVideo = useCallback(
    (e: React.FormEvent<HTMLFormElement>) => {
      e.preventDefault()
      const data = new FormData(e.currentTarget)
      const videoUrl = data.get('videoUrl')
      verifyVideo(videoUrl)
    },
    [verifyVideo]
  )

  return (
    <form onSubmit={handleRetrieveVideo}>
      <UploadVideoTextInput
        label="PASTE YOUR VIDEO URL (YOUTUBE)"
        name="videoUrl"
        error={retrievalError}
        errorMessage="This link is invalid, please check it again!"
        placeholder="Paste your video here"
      />
      <div className="flex">
        <button type="submit" className="w-full btn-primary btn-l grow">
          Retrieve video
        </button>
      </div>
    </form>
  )
}
