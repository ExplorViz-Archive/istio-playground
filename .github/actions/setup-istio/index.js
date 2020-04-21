const core = require('@actions/core');
const github = require('@actions/github');
const toolCache = require('@actions/tool-cache');

async function installIstio() {
  try {
    // `who-to-greet` input defined in action metadata file
    console.log(`Installing istio`);
    const version = '1.5.1'
    const OSEXT = 'linux'
    const url = `https://github.com/istio/istio/releases/download/${ISTIO_VERSION}/istio-${ISTIO_VERSION}-${OSEXT}.tar.gz`
    const downloadIstioScript = await toolCache.downloadTool(url);
  
    const tempDirectory = path.join('home', 'actions', 'temp');
    await toolCache.extractTar(downloadIstioScript, tempDirectory);
  
    const toolPath = await tc.cacheDir(tempDirectory, "istio", version);
    core.addPath(cachedPath);
    core.debug(`istio is cached under ${toolPath}`);
    core.addPath(path.join(toolPath, 'bin'));
  } catch (error) {
    core.setFailed(error.message);
  }
}

installIstio()