import React, { useCallback, useState } from 'react'
import { Modal } from '../Modal'
import {
  UploadVideoForm,
  RetrieveVideoForm,
  UploadVideoModalHeader,
  VideoDataResponse,
  ExerciseTrackIndicator,
} from './elements'
import { ThanksForSubmitting } from './ThanksForSubmitting'

type UploadVideoModalProps = {
  isOpen: boolean
  onClose: () => void
}

enum UploadSteps {
  RETRIEVE,
  UPLOAD,
  SUCCESS,
}

type UploadStatus = keyof typeof UploadSteps

export function UploadVideoModal({
  isOpen,
  onClose = () => console.log('closed'),
}: UploadVideoModalProps): JSX.Element {
  const [videoData, setVideoData] = useState<VideoDataResponse>(null)
  const [videoUploadStep, setVideoUploadStep] =
    useState<UploadStatus>('RETRIEVE')
  const [videoRetrievalFailure, setVideoRetrievalFailure] = useState(false)

  const handleClearRetrievedVideo = useCallback(() => {
    setVideoUploadStep('RETRIEVE')
    setVideoRetrievalFailure(false)
    setVideoData(null)
  }, [])

  function renderUploadSteps() {
    switch (videoUploadStep) {
      case 'RETRIEVE':
        return (
          <>
            <UploadVideoModalHeader />
            <ExerciseTrackIndicator
              exercise="Amusement Park"
              exerciseIconUrl="https://dg8krxphbh767.cloudfront.net/exercises/amusement-park.svg"
              track="Rust"
              trackIconUrl="https://dg8krxphbh767.cloudfront.net/tracks/rust.svg"
              videoRetrieved={false}
            />
            <RetrieveVideoForm
              isError={videoRetrievalFailure}
              onSuccess={(data) => {
                setVideoData(data)
                setVideoUploadStep('UPLOAD')
                setVideoRetrievalFailure(false)
              }}
              onError={() => setVideoRetrievalFailure(true)}
            />
          </>
        )
      case 'UPLOAD':
        return (
          <>
            <UploadVideoModalHeader />
            <ExerciseTrackIndicator
              exercise="Amusement Park"
              exerciseIconUrl="https://dg8krxphbh767.cloudfront.net/exercises/amusement-park.svg"
              track="Rust"
              trackIconUrl="https://dg8krxphbh767.cloudfront.net/tracks/rust.svg"
              videoRetrieved={true}
            />
            {videoData && (
              <UploadVideoForm
                onError={() => console.log('error')}
                onSuccess={() => setVideoUploadStep('SUCCESS')}
                onUseDifferentVideoClick={handleClearRetrievedVideo}
                data={videoData.communityVideo}
              />
            )}
          </>
        )

      case 'SUCCESS':
        return <ThanksForSubmitting onClick={onClose} />
    }
  }

  return (
    <Modal open={isOpen} onClose={onClose} ReactModalClassName="max-w-[780px]">
      {renderUploadSteps()}
    </Modal>
  )
}
