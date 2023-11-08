export type TagFlags = 'filterable' | 'enabled'

export type Tag = {
  tag: string
  numSolution: number
} & Record<TagFlags, boolean>

export type AnalyzerTagsType = {
  tags: Tag[]
  editor: boolean
  endpoints: AnalyzerTagsEndpoints
}

export type Links = {
  docsBuildingToolingAnalyzersTagsLink: string
}

export type AnalyzerTagsEndpoints = {
  filterable: string
  enabled: string
}
