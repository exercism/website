export type CommunityVideoUserLinks = {
  profile?: string
  channel_url?: string
}

export type CommunityVideoUser = {
  name: string
  handle: string
  avatarUrl: string
  links: CommunityVideoUserLinks
}

export type CommunityVideoPlatform = 'youtube' | 'vimeo'

export type CommunityVideoLinks = {
  watch: string
  embed: string
  channel: string
  thumbnail: string
}

export type CommunityVideo = {
  author?: CommunityVideoUser
  submittedBy: CommunityVideoUser
  platform: CommunityVideoPlatform
  title: string
  createdAt: string
  links: CommunityVideoLinks
}

export type CommunityVideosProps = {
  videos: CommunityVideo[]
}
