export type Tag = {
  tag: string
  enabled: boolean
  filterable: boolean
}
export type AnalyzerTagsType = {
  tags: {
    tags: Tag[]
    solutionCounts: Record<string, number>
  }
}

export type Links = {
  docsBuildingToolingAnalyzersTagsLink: string
}
