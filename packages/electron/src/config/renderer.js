const { schema } = require('./common')

const ALLOWED_IN_RENDERER = [
  // a list of config keys that are allowed to be supplied to the renderer client
  'onError', 'onBreadcrumb', 'logger', 'metadata', 'user', 'context', 'codeBundleId', 'plugins'
]

module.exports.schema = {
  ...schema,
  releaseStage: {
    ...schema.releaseStage,
    defaultValue: () => null
  },
  logger: Object.assign({}, schema.logger, {
    defaultValue: () => getPrefixedConsole()
  })
}

module.exports.mergeOptions = (mainOpts, rendererOpts) => {
  return Object.keys(module.exports.schema).reduce((accum, k) => {
    if (rendererOpts[k]) {
      if (ALLOWED_IN_RENDERER.includes(k)) {
        if (k === 'metadata') {
          // ensure that metadata set in renderer config doesn't blow away all preexisting metadata
          return { ...accum, [k]: mergeMetadata(mainOpts[k], rendererOpts[k]) }
        } else {
          return { ...accum, [k]: rendererOpts[k] }
        }
      }
      console.warn(`[bugsnag] Cannot set "${k}" configuration option in renderer. This must be set in the main process.`)
    }
    return { ...accum, [k]: mainOpts[k] }
  }, {})
}

const getPrefixedConsole = () => {
  return ['debug', 'info', 'warn', 'error'].reduce((accum, method) => {
    const consoleMethod = console[method] || console.log
    accum[method] = consoleMethod.bind(console, '[bugsnag]')
    return accum
  }, {})
}

const mergeMetadata = (a, b) => {
  const aKeys = Object.keys(a)
  const bKeys = Object.keys(b)
  if (!bKeys.length) return a
  const sections = new Set([...aKeys, ...bKeys])
  const merged = {}
  sections.forEach(section => {
    merged[section] = {}
    Object.assign(merged[section], a[section], b[section])
  })
  return merged
}
