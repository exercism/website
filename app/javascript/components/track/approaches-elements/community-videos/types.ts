export type CommunityVideoAuthorLinks = {
  profile?: string
  channel_url?: string
}

export type CommunityVideoAuthor = {
  name: string
  handle: string
  avatarUrl: string
  links: CommunityVideoAuthorLinks
}

export type CommunityVideoPlatform = 'youtube' | 'vimeo'

export type CommunityVideoLinks = {
  watch: string
  embed: string
  channel: string
  thumbnail: string
}

export type CommunityVideo = {
  author?: CommunityVideoAuthor
  submittedBy: CommunityVideoAuthor
  thumbnailUrl?: string
  platform: CommunityVideoPlatform
  title: string
  createdAt: string
  links: CommunityVideoLinks
}

export type CommunityVideosProps = {
  videos: CommunityVideo[]
}
