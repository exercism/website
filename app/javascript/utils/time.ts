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

  if (relative == 'a few seconds ago' || relative === 'in a few seconds') {
    return 'now'
  }

  const parts = relative.split(' ')
  const inFuture = parts[0] === 'in'
  const time = inFuture ? [parts[1], parts[2]] : [parts[0], parts[1]]
  const val = time[0] == 'a' || time[0] == 'an' ? 1 : time[0]
  let unit

  switch (time[1]) {
    case 'month':
    case 'months':
      unit = 'mo'

      break
    default:
      unit = time[1][0]
  }

  return inFuture ? `in ${val}${unit}` : `${val}${unit} ago`
}

export function timeFormat(dateTime: ConfigType, template: string) {
  return dayjs(dateTime).format(template)
}
