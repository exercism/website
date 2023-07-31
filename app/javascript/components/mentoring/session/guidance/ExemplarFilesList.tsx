import React from 'react'
import { MentoringSessionExemplarFile } from '../../../types'

export type Props = {
  files: readonly MentoringSessionExemplarFile[]
  language: string
}

export const ExemplarFilesList = ({ files, language }: Props): JSX.Element => {
  return (
    <React.Fragment>
      {files.map((file) => (
        <ExemplarFile key={file.filename}>
          {files.length > 1 ? (
            <ExemplarFile.Header filename={file.filename} />
          ) : null}
          <ExemplarFile.Content content={file.content} language={language} />
        </ExemplarFile>
      ))}
    </React.Fragment>
  )
}

const ExemplarFile = ({ children }: { children?: React.ReactNode }) => {
  return <div className="exemplar-files">{children}</div>
}

ExemplarFile.Header = ({ filename }: { filename: string }) => {
  return <div className="filename">{filename}</div>
}

ExemplarFile.Content = ({
  content,
  language,
}: {
  content: string
  language: string
}) => {
  return (
    <pre className="overflow-auto">
      <code className={language}>{content}</code>
    </pre>
  )
}
