import manifest from '../.config/manifest.json'

export function assetUrl(baseUrl: string): string {
  return `${process.env.WEBSITE_ASSETS_HOST}/assets/${manifest[baseUrl]}`
}
