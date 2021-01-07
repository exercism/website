import React from 'react'
import { FileViewer } from './FileViewer'
import { useRequestQuery } from '../../../hooks/request-query'
import { File } from '../../types'

export const IterationFiles = ({
  endpoint,
  language,
}: {
  endpoint: string
  language: string
}): JSX.Element => {
  const { isSuccess, data } = useRequestQuery<{
    files: File[]
  }>(endpoint, { endpoint: endpoint, options: {} })

  if (isSuccess && data) {
    return (
      <div>
        {data.files.map((file) => (
          <FileViewer key={file.filename} file={file} language={language} />
        ))}
      </div>
    )
  } else {
    return null
  }
}
