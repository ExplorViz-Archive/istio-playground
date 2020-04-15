var webAuth = new auth0.WebAuth({
    domain: 'dev-0kw21a7w.auth0.com',
    clientID: 'obzrLluUpRf2C1XsaEbGsPK1IXTf2Xwl',
    audience: 'https://api.istio-test.com/',
    connection: 'github',
    redirectUri: `http://${window.location.host}/callback.html`
});