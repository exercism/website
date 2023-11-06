export type Tag = {
  tag: string
  enabled: boolean
  filterable: boolean
}
export type TrackStatusTagsType = {
  tags: {
    tags: Tag[]
    solutionCounts: Record<string, number>
  }
}

export type Links = {
  docsBuildingToolingAnalyzersTagsLink: string
}
