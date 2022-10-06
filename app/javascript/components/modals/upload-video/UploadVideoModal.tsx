import React, { useCallback, useState } from 'react'
import { Modal } from '../Modal'
import {
  UploadVideoForm,
  RetrieveVideoForm,
  UploadVideoModalHeader,
  VideoDataResponse,
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
  onClose,
}: UploadVideoModalProps): JSX.Element {
  const [videoData, setVideoData] = useState<VideoDataResponse>(null)
  const [videoUploadStep, setVideoUploadStep] =
    useState<UploadStatus>('RETRIEVE')

  const handleClearRetrievedVideo = useCallback(() => {
    setVideoUploadStep('RETRIEVE')
    setVideoData(null)
  }, [])

  function renderUploadSteps() {
    switch (videoUploadStep) {
      case 'RETRIEVE':
        return (
          <>
            <UploadVideoModalHeader />
            <RetrieveVideoForm
              onSuccess={(data) => {
                setVideoData(data)
                setVideoUploadStep('UPLOAD')
              }}
            />
          </>
        )
      case 'UPLOAD':
        return (
          <>
            <UploadVideoModalHeader videoRetrieved />
            {videoData && (
              <UploadVideoForm
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
    <Modal
      open={isOpen}
      onClose={() => {
        onClose()
        handleClearRetrievedVideo()
      }}
      closeButton
      ReactModalClassName="max-w-[780px]"
    >
      {renderUploadSteps()}
    </Modal>
  )
}
