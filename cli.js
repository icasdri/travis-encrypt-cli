const argv = process.argv.splice(2);
if (argv.length < 2) {
    console.error('Usage: node cli.js user/repo VAR=value');
    process.exit(1);
}

const repo = argv[0];
const plaintext = argv[1];

const https = require('https');
const NodeRSA = require('node-rsa');

https.request({
    hostname: 'api.travis-ci.org',
    path: '/repos/' + repo + '/key'
}, function(res) {
    var chunks = [];
    res.on('data', function(chunk) {
        chunks.push(chunk);
    });

    res.on('end', function() {
        var keyMaterial = chunks.join('');
    var keyString = JSON.parse(keyMaterial).key;
        var key = new NodeRSA(keyString);
        console.log(key.encrypt(plaintext, 'base64'));
    });
}).end();
