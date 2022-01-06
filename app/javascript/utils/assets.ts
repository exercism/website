import manifest from '../.manifest.json'

export function assetUrl(baseUrl: string): string {
  // TODO: use Exercism.config.website_assets_host
  return `assets/${manifest[baseUrl]}`
}
