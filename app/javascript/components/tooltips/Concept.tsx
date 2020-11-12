import React from 'react'
import { useQuery } from 'react-query'
// import { useRequestQuery } from '../../hooks/request-query'
import { Loading } from '../common/Loading'

// type ConceptTooltipData = {
//   conceptTooltipHTML: string
// }

export const Concept = ({
  endpoint,
  styles,
}: {
  endpoint: string
  styles?: React.CSSProperties
}): JSX.Element => {
  // const request = { endpoint: endpoint, options: {} }
  // const { isLoading, isError, isSuccess, data } = useRequestQuery<
  //   ConceptTooltipData
  // >('concept-tooltip', request)

  const { isLoading, isError, data } = useQuery('concept-tooltip', () =>
    fetch(endpoint)
  )

  styles = { ...styles, position: 'absolute', zIndex: 10, top: 100 }

  if (isLoading || isError) {
    return (
      <div className="c-tooltip c-concept-tooltip" style={styles}>
        {isLoading && <Loading />}
        {isError && <p>Something went wrong</p>}
      </div>
    )
  }

  console.log(data)

  return (
    <div
      className="c-tooltip c-concept-tooltip"
      style={styles}
      // dangerouslySetInnerHTML={{ __html: data }}
    ></div>
  )
}
