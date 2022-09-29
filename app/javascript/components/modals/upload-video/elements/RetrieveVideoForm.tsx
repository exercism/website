import React, { useCallback } from 'react'
import { useMutation } from 'react-query'
import { UploadVideoTextInput } from '.'
import { sendRequest } from '../../../../utils/send-request'

export type CommunityVideo = {
  id: any
  trackId: any
  exerciseId: any
  authorId: any
  submittedById: any
  title: string
  url: string
  platform: string
  watchId: string
  embedId: string
  channelName: string
  thumbnailUrl: string
  createdAt: any
  updatedAt: any
}

export type VideoDataResponse =
  | { communityVideo: CommunityVideo }
  | undefined
  | null

type RetrieveVideoForm = {
  isError: boolean
  onError: () => void
  onSuccess: (data: VideoDataResponse) => void
}

export function RetrieveVideoForm({
  onSuccess,
  onError,
  isError,
}: RetrieveVideoForm): JSX.Element {
  async function VerifyVideo(link: string) {
    const URL = `http://local.exercism.io:3020/api/v2/community_videos/lookup?video_url=${link}`
    const { fetch } = sendRequest({ endpoint: URL, body: null, method: 'GET' })
    return fetch
  }

  const [verifyVideo] = useMutation((url: any) => VerifyVideo(url), {
    onSuccess: (data: VideoDataResponse) => onSuccess(data),
    onError: () => onError(),
  })

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
        label="PASTE YOUR VIDEO URL (YOUTUBE / VIMEO)"
        name="videoUrl"
        error={isError}
        errorMessage="This ain't no Youtube video!"
      />
      <div className="flex">
        <button type="submit" className="w-full btn-primary btn-l grow">
          Retrieve video
        </button>
      </div>
    </form>
  )
}
