import dayjs from 'dayjs'
import type { ConfigType } from 'dayjs'
import RelativeTime from 'dayjs/plugin/relativeTime'
dayjs.extend(RelativeTime)

// The short flag turns "2 days ago" into "2d ago"
export function fromNow(dateTime: ConfigType, short?: boolean) {
  const relative = dayjs(dateTime).fromNow()
  if (short) {
    const parts = relative.split(' ')
    return `${parts[0]}${parts[1][0]} ${parts[2]}`
  } else {
    return relative
  }
}

export function timeFormat(dateTime: ConfigType, template: string) {
  return dayjs(dateTime).format(template)
}
