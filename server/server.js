//  GET http://pancake.ftaires.com/ndnichols/wondew?regex=#new
//  POST http://pancake.ftaires.com/ndnichols/wondew body of JSON files
//
//

var sys = require("sys"),
    http = require("http"),
    url = require("url"),
    path = require("path"),
    fs = require("fs"),
    events = require("events"),
    flatfile = require("./flatfile");
    
var base_dir = '/Users/nate/Programming/PancakeJS/data'

var safePathRegex = /[\w\/#]/g

function pathOK(path) {
    return path.match(safePathRegex);
}

function writeJSON(status, data, res) {
    if (status != 200) {
        data = {'status':'error', 'msg':data};
    }
    res.writeHead(status, {'Content-Type':'application/json'});
    res.write(JSON.stringify(data));
    res.end();
}

function handleRequest(res, func, filename, secret, args) {
    flatfile.executeOnFile(func, filename, secret, args, function(status, data) {writeJSON(status, data, res);});
}
    
var server = http.createServer(function(req, res) {
    var parsed_req = url.parse(req.url, true);
    var path = parsed_req.pathname;
    if (!pathOK(path)) {
        res.writeHead(403, {'Content-Type': 'text/html'});
    	res.write('Bad path, are you trying to be sneaky?', 'utf-8');
    	res.end();
    	return;
    }

    var username = path.split('/')[1];
    var application_name = path.split('/')[2];
    var args = parsed_req.query;
    var secret = args['secret'];
    args.limit = args.limit ? parseInt(args.limit, 10) : 0; //a lot of flatfile.js uses limit and offset
    args.offset = args.offset ? parseInt(args.offset, 10) : 0;
    sys.puts('args is ' + sys.inspect(args));
    var filename = base_dir + '/' + username + '/' + application_name + '.txt';
    
    switch(req.method) {
        case 'GET':
            handleRequest(res, flatfile.findAllInFile, filename, secret, args);
        break;
        case 'POST':
            var endpoint = path.split('/')[3];
            if (endpoint == 'append_lines') {
                args.lines = JSON.parse(args.lines);
                handleRequest(res, flatfile.appendToFile, filename, secret, args);                
            }
            else if (endpoint == 'modify_lines') {
                handleRequest(res, flatfile.updateLines, filename, secret, args);
            }
            else if (endpoint == 'set_tags') {
                handleRequest(res, flatfile.setTags, filename, secret, args);
            }
            else if (endpoint == 'remove_tags') {
                handleRequest(res, flatfile.removeTags, filename, secret, args);
            }
            else {
                res.writeHead(404, {'Content-Type':'text/html'});
                res.write("I don't know that endpoint!");
                res.end();
            }
        break;
        case 'DELETE':
            handleRequest(res, flatfile.filterFile, filename, secret, args);
        break;
        case 'PUT':
            args.lines = JSON.parse(args.lines);
            handleRequest(res, flatfile.replaceFile, filename, secret, args);
        break;
    }
    
    // res.writeHead(200, {'Content-Type': 'text/html'});
    // res.write('Ok', 'utf-8');
    // res.end();
});
    
server.listen(8080);

sys.puts("Server running at http://localhost:8080/");