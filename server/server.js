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
    
var base_dir = '/Users/nate/Desktop/data'

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

function handleRequest(res, func, filename, perm_string, args) {
    flatfile.executeOnFile(func, filename, perm_string, args, function(status, data) {writeJSON(status, data, res);});
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
    var perm_string = args['ps'];
    var filename = base_dir + '/' + username + '/' + application_name + '.txt';
    sys.puts("username is " + username + " and application_name is " + application_name + " and perm_string is " + perm_string);
    sys.puts("regex is " + args.regex);
    
    switch(req.method) {
        case 'GET':
            handleRequest(res, flatfile.findAllInFile, filename, perm_string, args);
        break;
        case 'POST':
            args.lines = JSON.parse(args.lines);
            handleRequest(res, flatfile.appendToFile, filename, perm_string, args);
        break;
        case 'DELETE':
            handleRequest(res, flatfile.filterFile, filename, perm_string, args);
        break;
        case 'PUT':
            args.lines = JSON.parse(args.lines);
            handleRequest(res, flatfile.replaceFile, filename, perm_string, args);
        break;
    }
    
    // res.writeHead(200, {'Content-Type': 'text/html'});
    // res.write('Ok', 'utf-8');
    // res.end();
});
    
server.listen(8080);

sys.puts("Server running at http://localhost:8080/");