import React from 'react'

import { ConceptPath } from './concept-map-types'
import { computeBezier } from './helpers/svg-draw-helpers'

export const PathLineSVG = ({ path }: { path: ConceptPath }) => {
  return (
    <path d={computeBezier(path)} className={`line-width-2 ${path.status}`} />
  )
}
