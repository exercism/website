import React, { useCallback, useState } from 'react'
import { useMutation } from 'react-query'
import { useLogger } from '../../../hooks'
import { sendRequest } from '../../../utils/send-request'
import { Modal } from '../Modal'
import {
  ExerciseTrackIndicator,
  UploadVideoTextInput,
  UploadVideoForm,
} from './elements'

type UploadVideoModalProps = {
  isOpen: boolean
}

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
  | {
      communityVideo: CommunityVideo
    }
  | undefined
  | null

export function UploadVideoModal({
  isOpen,
}: UploadVideoModalProps): JSX.Element {
  const [videoData, setVideoData] = useState<VideoDataResponse>(null)
  const [videoRetrievalSuccess, setVideoRetrievalSucces] = useState(false)
  const [videoRetrievalFailure, setVideoRetrievalFailure] = useState(false)

  useLogger('VIDEO_DATA', videoData)

  async function VerifyVideo(link: string) {
    const URL = `http://local.exercism.io:3020/api/v2/community_videos/lookup?video_url=${link}`
    const { fetch } = sendRequest({ endpoint: URL, body: null, method: 'GET' })
    return fetch
  }

  const [verifyVideo] = useMutation((url: any) => VerifyVideo(url), {
    onSuccess: (data: VideoDataResponse) => {
      setVideoData(data)
      setVideoRetrievalSucces(true)
      setVideoRetrievalFailure(false)
    },
    onError: () => setVideoRetrievalFailure(true),
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

  const handleClearRetrievedVideo = useCallback(() => {
    setVideoRetrievalSucces(false)
    setVideoRetrievalFailure(false)
    setVideoData(null)
  }, [])

  return (
    <Modal
      open={isOpen}
      onClose={() => console.log('hello')}
      ReactModalClassName="max-w-[780px]"
    >
      <h2 className="text-h2 mb-8">Submit a community workthrough</h2>
      <p className="text-prose mb-24">
        Produced a video of working through this exercise yourself? Want to
        share it with the Exercism community?{' '}
        <strong className="font-medium text">
          Submit the form below and Jonathan (our community manager) will review
          and approve it.
        </strong>
      </p>

      <ExerciseTrackIndicator
        exercise="Amusement Park"
        exerciseIconUrl="https://dg8krxphbh767.cloudfront.net/exercises/amusement-park.svg"
        track="Rust"
        trackIconUrl="https://dg8krxphbh767.cloudfront.net/tracks/rust.svg"
        videoSubmitted={videoRetrievalSuccess}
      />

      {videoRetrievalSuccess && videoData ? (
        <UploadVideoForm
          onUseDifferentVideoClick={handleClearRetrievedVideo}
          data={videoData.communityVideo}
        />
      ) : (
        <RetrieveVideoForm
          isError={videoRetrievalFailure}
          onSubmit={handleRetrieveVideo}
        />
      )}
    </Modal>
  )
}

type RetrieveVideoForm = {
  onSubmit: (e: React.FormEvent<HTMLFormElement>) => void
  isError: boolean
}

function RetrieveVideoForm({
  onSubmit,
  isError,
}: RetrieveVideoForm): JSX.Element {
  return (
    <form onSubmit={onSubmit}>
      <UploadVideoTextInput
        label="PASTE YOUR VIDEO URL (YOUTUBE / VIMEO)"
        name="videoUrl"
        error={isError}
      />
      <div className="flex">
        <button type="submit" className="w-full btn-primary btn-l grow">
          Retrieve video
        </button>
      </div>
    </form>
  )
}
