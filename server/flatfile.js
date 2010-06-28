var sys = require('sys'),
    fs = require('fs'),
    Buffer = require('buffer').Buffer;
    
var PERM_GET = 1,
    PERM_POST = 2,
    PERM_PUT = 3,
    PERM_DELETE = 4;
    
function hasPermissions(permissions, perm_string, permission_type) {
    var permissions = permissions.split('|');
    var match_string = permissions[permission_type];// || permissions[0];
    if (('/' == match_string[0]) && ('/' == match_string[match_string.length - 1])) {
        match_string = new RegExp(match_string.slice(1, match_string.length - 1));
        return perm_string.match(match_string) || perm_string == permissions[0];
    }
    else {
        return perm_string == match_string || perm_string == permissions[0];
    }
}
    
exports.executeOnFile = function(f, path, perm_string, args, response_callback) {
    fs.stat(path, function(error, stats) {
        if (error) {//Doesn't exist yet, does the user?
            var parts = path.split('/');
            var dir_path = parts.slice(0, parts.length - 1).join('/');
            try {
                fs.statSync(dir_path);
            }
            catch (error) {
                fs.mkdirSync(dir_path, 0777);
            }
            fs.open(path, 'w', 0777, function(error, fd) {
                var buff = new Buffer(perm_string + '||||\n', 'utf8');
                fs.write(fd, buff, 0, buff.length, null, function(err, written){
                    fs.close(fd, function(error, fd) {
                        f(path, perm_string, args, response_callback);
                    });
                });
            });
        }
        else {
            f(path, perm_string, args, response_callback);
        }
    });
}

exports.findAllInFile = function(path, perm_string, args, response_callback) {
    var regex = new RegExp(args.regex);
    var ret = []
    fs.readFile(path, 'utf8', function(err, data) {
        if (!data) return;
        var lines = data.split('\n');
        if (!hasPermissions(lines[0], perm_string, PERM_GET)) {
            response_callback(403, "You don't have GET permissions for file " + path);
            // WriteForbidden(res, );
            return;
        }
        for (var i = 1; i < lines.length-1; i++) { //last line is empty so -1
            var line = lines[i];
            if (line.match(regex)) {
                ret.push({'text':line});
            }
        }
        sys.puts(ret.length);
        response_callback(200, {'status':'ok', 'results':ret});
    });    
}

exports.appendToFile = function(path, perm_string, args, response_callback) {
    var lines = args.lines;
    var text = lines.join('\n') + '\n';
    var buff = new Buffer(text, 'utf8');
    fs.open(path, 'r', 0777, function(error, fd) {
        var perm_buff = new Buffer(255);
        fs.readSync(fd, perm_buff, 0, 255, null);
        fs.read(fd, perm_buff, 0, 255, null, function (error, bytesRead) {
            var permissions = perm_buff.toString('utf8', 0, bytesRead);
            permissions = permissions.slice(0, permissions.indexOf('\n'));
            if (!hasPermissions(permissions, perm_string, PERM_POST)) {
                response_callback(403, "You don't have POST permissions for file " + path);
                // WriteForbidden(res, );
                fs.close(fd);
            }
            else {
                fs.close(fd, function(error) {
                    fs.open(path, 'a+', 0777, function(error, fd) {
                        fs.write(fd, buff, 0, buff.length, null, function(err, written){
                            fs.close(fd);
                            response_callback(200, {'status':'ok'});
                        });
                    });                    
                });
            }
        });
    });
}

exports.filterFile = function(path, perm_string, args, response_callback) {
    sys.puts('remove_regex is ' + remove_regex);
    var remove_regex = new RegExp(args.regex);
    sys.puts('remove_regex is ' + remove_regex);
    var good_lines = []
    fs.readFile(path, 'utf8', function(err, data) {
        if (!data) return;
        var lines = data.split('\n');
        if (!hasPermissions(lines[0], perm_string, PERM_DELETE)) {
            response_callback(403, "You don't have DELETE permissions for file " + path);
            return;
        }
        good_lines.push(lines[0]); //Keep permission line the same.
        for (var i = 1; i < lines.length; i++) {
            var line = lines[i];
            if ((line) && (!line.match(remove_regex))) {
                good_lines.push(line);
            }
        }
        var new_text = good_lines.join('\n') + '\n';
        fs.writeFile(path, new_text);
        response_callback(200, {'status':'ok'});
    });
}

exports.replaceFile = function(path, perm_string, args, response_callback) {
    var lines = args.lines;
    fs.open(path, 'r', 0777, function(error, fd) {
        var perm_buff = new Buffer(255);
        fs.read(fd, perm_buff, 0, 255, 0, function (error, bytesRead) {
            var permissions = perm_buff.toString('utf8', 0, bytesRead);
            permissions = permissions.slice(0, permissions.indexOf('\n'));
            if (!hasPermissions(permissions, perm_string, PERM_PUT)) {
                response_callback(403, "You don't have PUT permissions for file " + path);
                return;
            }
            else {
                fs.close(fd, function(error) {
                    var text = permissions + '\n' + lines.join('\n') + '\n';
                    fs.writeFile(path, text);
                    response_callback(200, {'status':'ok'});    
                });
            }
        });
    });
}

if (module.id == require.main.id) {
    var path = '/Users/nate/Desktop/baz/overhead.txt';
    var res = null;
    // replaceFile(path, ['Hey', 'is', 'this', 'cool?']);
    // filterFile(path, /a/g);
    executeOnFile(appendToFile, path, 'Foo', {'lines':['The new way works', 'indeed!']});//function(path, perm_string) {
//        replaceFile(path, 'Foo', ['For', 'real!']);
        // filterFile(path, perm_string, /a/g)
        // appendToFile(path, perm_string, ['last', 'bit', 'with', 'closing']);
        // findAllInFile(path, perm_string, /Emily/);
  //  });
    // var f = function(path) {findAll(path, /cows/g)};
    // executeOnFile('/Users/nate/Desktop/overhead.txt', f);
}
