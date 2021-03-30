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
  if (relative == 'a few seconds ago') {
    return 'now'
  }

  const parts = relative.split(' ')
  const val = parts[0] == 'a' || parts[0] == 'an' ? 1 : parts[0]
  const unit = parts[1][0]
  return `${val}${unit} ago`
}

export function timeFormat(dateTime: ConfigType, template: string) {
  return dayjs(dateTime).format(template)
}
