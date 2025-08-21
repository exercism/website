import xxhash from 'xxhashjs'

const seed = 0xbadc0ffee

export function hashQueryKey({
  prefix,
  data,
}: {
  prefix: string
  data: Object
}) {
  const queryKey = `${prefix}:${xxhash
    .h64(JSON.stringify(data), seed)
    .toString(16)}`

  return queryKey
}
