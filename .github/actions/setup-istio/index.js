const core = require('@actions/core');
const github = require('@actions/github');
const toolCache = require('@actions/tool-cache');
const path = require('path');

async function installIstio() {
  try {
    // `who-to-greet` input defined in action metadata file
    console.log(`Installing istio`);
    const version = '1.5.1'
    const OSEXT = 'linux'
    const url = `https://github.com/istio/istio/releases/download/${version}/istio-${version}-${OSEXT}.tar.gz`
    const downloadIstioScript = await toolCache.downloadTool(url);
  
    const tempDirectory = path.join('home', 'actions', 'temp');
    await toolCache.extractTar(downloadIstioScript, tempDirectory);
  
    const toolPath = await toolCache.cacheDir(tempDirectory, "istio", version);
    core.addPath(cachedPath);
    core.debug(`istio is cached under ${toolPath}`);
    core.addPath(path.join(toolPath, 'bin'));
  } catch (error) {
    core.setFailed(error.message);
  }
}

installIstio()