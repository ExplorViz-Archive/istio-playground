const core = require('@actions/core');
const github = require('@actions/github');
const exec = require('@actions/exec');
const toolCache = require('@actions/tool-cache');
const path = require('path');

async function installIstio() {
  try {
    // `who-to-greet` input defined in action metadata file
    console.log(`Downloading istio...`);
    const version = core.getInput('version');
    const os = 'linux'
    const url = `https://github.com/istio/istio/releases/download/${version}/istio-${version}-${os}.tar.gz`
    const downloadIstioScript = await toolCache.downloadTool(url);
    console.log(`Downloaded istio.`);

    console.log(`Installing istio.`);
    const tempDirectory = path.join('home', 'actions', 'temp');
    await toolCache.extractTar(downloadIstioScript, tempDirectory);
    
    const toolPath = await toolCache.cacheDir(tempDirectory, "istio-", version);
    const binPath = path.join(toolPath, 'bin');
    console.log(`Adding to path: ${binPath}`);
    core.addPath(binPath);
    core.debug(`istio is cached under ${binPath}`);
    await exec.exec(`ls -la ${binPath}`);
    await exec.exec('istioctl manifest apply --set profile=default');
  } catch (error) {
    core.setFailed(error.message);
  }
}

installIstio();