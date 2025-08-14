import React from 'react'
import { useRequestQuery, Request } from '../../../hooks/request-query'
import { Loading } from '../../common/Loading'
import { TrackList, Track } from './TrackList'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const TrackFilter = ({
  request,
  value,
  setTrack,
}: {
  request: Request
  value: string | null
  setTrack: (track: string | null) => void
}): JSX.Element => {
  const { t } = useAppTranslation('components/mentoring/inbox')

  const {
    isLoading,
    isError,
    data: tracks,
  } = useRequestQuery<Track[]>(['track-filter', request.query], request)

  return (
    <div className="c-track-filter">
      {isLoading && <Loading />}
      {isError && <p>{t('trackFilter.somethingWentWrong')}</p>}
      {tracks && (
        <TrackList tracks={tracks} setTrack={setTrack} value={value} />
      )}
    </div>
  )
}
