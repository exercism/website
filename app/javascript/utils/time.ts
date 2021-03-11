import dayjs from 'dayjs'
import type { ConfigType } from 'dayjs'
import RelativeTime from 'dayjs/plugin/relativeTime'
dayjs.extend(RelativeTime)

// The short flag turns "2 days ago" into "2d ago"
export function fromNow(dateTime: ConfigType) {
  return dayjs(dateTime).fromNow()
}

export function shortFromNow(dateTime: ConfigType) {
  const relative = fromNow(dateTime)
  const parts = relative.split(' ')
  return `${parts[0]}${parts[1][0]} ${parts[2]}`
}

export function timeFormat(dateTime: ConfigType, template: string) {
  return dayjs(dateTime).format(template)
}
