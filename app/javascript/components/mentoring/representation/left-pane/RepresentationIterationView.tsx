import React from 'react'
import { fromNow } from '../../../../utils/date'
import { pluralizeWithNumber } from '../../../../utils/pluralizeWithNumber'
import { ResultsZone } from '../../../ResultsZone'
import { RepresentationData } from '../../../types'
import { MostPopularTag } from '../../automation/MostPopularTag'
import { FilePanel } from '../../session/FilePanel'

export const IterationView = ({
  representationData,
}: {
  representationData: RepresentationData
}): JSX.Element => {
  return (
    <React.Fragment>
      <SimpleIterationHeader
        solutionNumber={representationData.id}
        appearsFrequently={representationData.appearsFrequently}
        lastOccurred={fromNow(representationData.lastSubmittedAt)}
        occurrenceNumber={representationData.numSubmissions}
      />
      <ResultsZone isFetching={false}>
        <FilePanel
          files={representationData.files}
          language={representationData.track.highlightjsLanguage}
          indentSize={2}
          instructions={representationData.instructions}
          testFiles={representationData.testFiles}
        />
      </ResultsZone>
    </React.Fragment>
  )
}

export function SimpleIterationHeader({
  solutionNumber,
  occurrenceNumber,
  lastOccurred,
  appearsFrequently,
}: {
  solutionNumber: number
  occurrenceNumber: number
  lastOccurred: string
  appearsFrequently: boolean
}): JSX.Element {
  return (
    <header className="iteration-header">
      <div>
        <div className="flex flex-row items-center text-15 text-textColor1 font-semibold leading-170">
          Solution #{solutionNumber} {appearsFrequently && <MostPopularTag />}
        </div>
        <div className="text-14 text-textColor6 font-medium leading-160">
          {pluralizeWithNumber(occurrenceNumber, 'occurrence')} · Last occurred{' '}
          {lastOccurred}
        </div>
      </div>
      <div></div>
    </header>
  )
}
