import React, { useCallback, useState } from 'react'
import { Modal } from '../Modal'
import {
  UploadVideoForm,
  RetrieveVideoForm,
  UploadVideoModalHeader,
  VideoDataResponse,
} from './elements'

type UploadVideoModalProps = {
  isOpen: boolean
}

export function UploadVideoModal({
  isOpen,
}: UploadVideoModalProps): JSX.Element {
  const [videoData, setVideoData] = useState<VideoDataResponse>(null)
  // TODO: change these into one enum state e.g. videoState === 'success' || 'failure' || 'submitted'
  const [videoRetrievalSuccess, setVideoRetrievalSuccess] = useState(false)
  const [videoRetrievalFailure, setVideoRetrievalFailure] = useState(false)

  const handleClearRetrievedVideo = useCallback(() => {
    setVideoRetrievalSuccess(false)
    setVideoRetrievalFailure(false)
    setVideoData(null)
  }, [])

  return (
    <Modal
      open={isOpen}
      onClose={() => console.log('hello')}
      ReactModalClassName="max-w-[780px]"
    >
      <UploadVideoModalHeader videoSubmitted={videoRetrievalSuccess} />

      {videoRetrievalSuccess && videoData ? (
        <UploadVideoForm
          onError={() => console.log('error')}
          onSuccess={() => console.log('SUCCESS!!')}
          onUseDifferentVideoClick={handleClearRetrievedVideo}
          data={videoData.communityVideo}
        />
      ) : (
        <RetrieveVideoForm
          isError={videoRetrievalFailure}
          onSuccess={(data) => {
            setVideoData(data)
            setVideoRetrievalSuccess(true)
            setVideoRetrievalFailure(false)
          }}
          onError={() => setVideoRetrievalFailure(true)}
        />
      )}
    </Modal>
  )
}
