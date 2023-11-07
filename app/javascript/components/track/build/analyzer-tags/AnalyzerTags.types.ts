export type Tag = {
  tag: string
  enabled: boolean
  filterable: boolean
  numSolution: number
}
export type AnalyzerTagsType = {
  tags: Tag[]
  editor: boolean
}

export type Links = {
  docsBuildingToolingAnalyzersTagsLink: string
}
