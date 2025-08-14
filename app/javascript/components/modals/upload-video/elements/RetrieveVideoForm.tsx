import React, { useCallback, useContext, useState } from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { DigDeeperDataContext } from '@/components/track/DigDeeper'
import type { CommunityVideoType } from '@/components/types'
import { UploadVideoTextInput } from '.'
import { useAppTranslation } from '@/i18n/useAppTranslation'

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
  const { t } = useAppTranslation('components/modals/upload-video/elements')

  async function VerifyVideo(link: string) {
    const URL = `${links.video.lookup}?video_url=${link}`
    const { fetch } = sendRequest({ endpoint: URL, body: null, method: 'GET' })
    return fetch
  }

  const [retrievalError, setRetrievalError] = useState(false)

  const { mutate: verifyVideo } = useMutation({
    mutationFn: async (url: any) => VerifyVideo(url),
    onSuccess: (data: VideoDataResponse) => onSuccess(data),
    onError: () => setRetrievalError(true),
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
        label={t('retrieveVideoForm.pasteYourVideoUrlYoutube')}
        name="videoUrl"
        error={retrievalError}
        errorMessage={t(
          'retrieveVideoForm.thisLinkIsInvalidPleaseCheckItAgain'
        )}
        placeholder={t('retrieveVideoForm.pasteYourVideoHere')}
      />
      <div className="flex">
        <button type="submit" className="w-full btn-primary btn-l grow">
          {t('retrieveVideoForm.retrieveVideo')}
        </button>
      </div>
    </form>
  )
}
