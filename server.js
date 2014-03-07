var hyperquest = require('hyperquest'); // this is a stream friendly http request module from Substack
var http = require('http');

var server = http.createServer(handler);
var streambank = {};

function streamData(req, token) {
    req.setEncoding('utf-8');
    req.on('data', function(data) {
        console.log(data);
        streambank[token].write(data+'\n');
    });
}

//var plotly = hyperquest(httpOpts);

function handler(req,res) {
    req.on('error', function() {
        console.log('disconnected');
    });

    var token = req.headers['plotly-streamtoken'];
    if (token in streambank) {
        streamData(req, token);
    } else {
        console.log('setting up token and stream!');
        var httpOpts =  {
            method: 'POST',
            uri: "http://stream.plot.ly/",
            headers: {
              "plotly-streamtoken": token
            }
        };
        streambank[token] = hyperquest(httpOpts);
        streambank[token].on('error', function() {
            delete streambank[token];
            console.log('disconnected');
        });
        streamData(req, token);
    }
    res.writeHead(200,{"Content-Type": "text/html"});
    res.write('posted!');
    res.end();
}

server.listen(9999);


