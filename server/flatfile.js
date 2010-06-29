var sys = require('sys'),
    fs = require('fs'),
    Buffer = require('buffer').Buffer;
    
var PERM_READ = 1,
    PERM_WRITE = 2,
    PERM_DELETE = 3;
    
var modified_regex = /#modified\([\d]+\)/;
    
function removeTag(line, tag) {
    var tagname = tag.split('(')[0];
    var tag_regex = new RegExp(' ' + tagname + '(?:\\(.*?\\))?');
    sys.puts('tag_regex is ' + tag_regex);
    return line.replace(tag_regex, '');
}

function setTag(line, tag) {
    //Tag can be like #foo or #foo(bar)
    if (tag[0] != '#') {
        tag = '#' + tag;
    }
    var exists_regex = new RegExp(tag + '[ $]');
    sys.puts('exists_regex is ' + exists_regex + ' and i\'m testing against' + line);
    if (line.match(exists_regex)) {
        sys.puts('yep it matched!');
        return line;
    }
    sys.puts('and it didnt match!');
    line = removeTag(line, tag);
    return line + ' ' + tag;
}

function updateTimestamp(line) {
    var new_modified = "#modified(" + (new Date).getTime() + ")";
    return setTag(line, new_modified);
}
    
function hasPermissions(permissions, secret, permission_type) {
    var permissions = permissions.split('|');
    var match_string = permissions[permission_type];// || permissions[0];
    if (('/' == match_string[0]) && ('/' == match_string[match_string.length - 1])) {
        match_string = new RegExp(match_string.slice(1, match_string.length - 1));
        return secret.match(match_string) || secret == permissions[0];
    }
    else {
        return secret == match_string || secret == permissions[0];
    }
}

function parseLine(line) {
    //Takes a like like "Hey, my name is nate #modified(1471) #foo(bar) #baz" and returns
    //{'original_text':(the text), 'text', 'tags':{'modified':1471, 'foo':'bar', 'baz':undefined}}
    var ret = {'original_text':line, 'tags':{}};
    var tag_regex = / #([\w]+)(\([\w\d\.]+\))?/g;
    while (true) {
        var match = tag_regex.exec(line);
        if (!match) {
            ret.text = ret.text || line;
            break;
        }
        ret.text = ret.text || line.slice(0, match.index);
        ret.tags[match[1]] = match[2] ? match[2].slice(1, match[2].length-1) : true;
    }
    return ret;
}

function modifyLines(path, secret, args, response_callback, modifyLine) {
    var new_lines = [];
    var num_lines_altered = 0;
    fs.readFile(path, 'utf8', function(err, data) {
        if (!data) return;  // I still don't know why this is necessary
        var lines = data.split('\n');
        if ((!hasPermissions(lines[0], secret, PERM_WRITE)) ||
            (!hasPermissions(lines[0], secret, PERM_DELETE))) {
            response_callback(403, "You don't have WRITE or DELETE permissions for file " + path);
            return;
        }
        new_lines.push(lines[0]); //Keep permission line the same.
        for (var i = 1; i < lines.length; i++) {        
            if (!lines[i]) continue;
            if (i < args.offset + 1) {
                new_lines.push(lines[i]);
                continue;
            }
            var new_line = modifyLine(lines[i]);
            if (new_line != lines[i]) {
                num_lines_altered++;
            }
            if (!new_line) continue;
            if ((!args.limit) || 
                ((args.limit) && (num_lines_altered <= args.limit))) {
                new_lines.push(new_line);                
            }
            else {
                sys.puts('breaking because of limit');
                new_lines.push(lines[i]);//Push original once we hit limit
            }
        }
        var new_text = new_lines.join('\n') + '\n';
        fs.writeFile(path, new_text);
        response_callback(200, {'status':'ok'});
    });
}

exports.executeOnFile = function(f, path, secret, args, response_callback) {
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
                var buff = new Buffer(secret + '|||\n', 'utf8');
                fs.write(fd, buff, 0, buff.length, null, function(err, written){
                    fs.close(fd, function(error, fd) {
                        f(path, secret, args, response_callback);
                    });
                });
            });
        }
        else {
            f(path, secret, args, response_callback);
        }
    });
}

exports.findAllInFile = function(path, secret, args, response_callback) {
    var regex = new RegExp(args.regex);
    var ret = []
    fs.readFile(path, 'utf8', function(err, data) {
        if (!data) return;
        var lines = data.split('\n');
        if (!hasPermissions(lines[0], secret, PERM_READ)) {
            response_callback(403, "You don't have GET permissions for file " + path);
            // WriteForbidden(res, );
            return;
        }
        for (var i = 1; i < lines.length-1; i++) { //last line is empty so -1
            if (i < args.offset + 1) {
                continue;
            }
            var line = lines[i];
            if (line.match(regex)) {
                ret.push(parseLine(line));
            }
            if ((args.limit) && (ret.length == args.limit)) {
                break;
            }
        }
        response_callback(200, {'status':'ok', 'results':ret});
    });    
}

exports.appendToFile = function(path, secret, args, response_callback) {
    sys.puts('in AppendToFile!!');
    var lines = args.lines;
    for (var i = 0; i < lines.length; i++) {
        lines[i] = updateTimestamp(lines[i]);
    }
    var text = lines.join('\n') + '\n';
    var buff = new Buffer(text, 'utf8');
    sys.puts('made buffer!');
    fs.open(path, 'r', 0777, function(error, fd) {
        var perm_buff = new Buffer(255);
        fs.readSync(fd, perm_buff, 0, 255, null);
        fs.read(fd, perm_buff, 0, 255, null, function (error, bytesRead) {
            var permissions = perm_buff.toString('utf8', 0, bytesRead);
            permissions = permissions.slice(0, permissions.indexOf('\n'));
            if (!hasPermissions(permissions, secret, PERM_WRITE)) {
                response_callback(403, "You don't have POST permissions for file " + path);
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

exports.filterFile = function(path, secret, args, response_callback) {
    var remove_regex = new RegExp(args.regex);
    var good_lines = [];
    var num_deleted = 0;
    fs.readFile(path, 'utf8', function(err, data) {
        if (!data) return;
        var lines = data.split('\n');
        if (!hasPermissions(lines[0], secret, PERM_DELETE)) {
            response_callback(403, "You don't have DELETE permissions for file " + path);
            return;
        }
        good_lines.push(lines[0]); //Keep permission line the same.
        for (var i = 1; i < lines.length; i++) {
            var line = lines[i];
            if (line) {
                if (i < args.offset + 1) {
                    good_lines.push(line);
                    continue;
                }
                if ((!line.match(remove_regex) ||
                    ((args.limit) && (num_deleted >= args.limit)))) { //If it doesn't match the bad filter, or we've already deleted enough
                    good_lines.push(line);
                }
                else {
                    num_deleted++;
                }
            }
        }
        var new_text = good_lines.join('\n') + '\n';
        fs.writeFile(path, new_text);
        response_callback(200, {'status':'ok'});
    });
}

exports.replaceFile = function(path, secret, args, response_callback) {
    var lines = args.lines;
    for (var i = 0; i < lines.length; i++) {
        lines[i] = updateTimestamp(lines[i]);
    }
    fs.open(path, 'r', 0777, function(error, fd) {
        var perm_buff = new Buffer(255);
        fs.read(fd, perm_buff, 0, 255, 0, function (error, bytesRead) {
            var permissions = perm_buff.toString('utf8', 0, bytesRead);
            permissions = permissions.slice(0, permissions.indexOf('\n'));
            if (!hasPermissions(permissions, secret, PERM_WRITE)) {
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

exports.updateLines = function(path, secret, args, response_callback) {
    var match_regex = new RegExp(args.regex);
    var replace_string = args.replace_string;
    
    var func = function(line) {
        var ret = line.replace(match_regex, replace_string);
        // if (ret != line) {
        //     ret = updateTimestamp(ret);
        // }
        return ret;
    }
    modifyLines(path, secret, args, response_callback, func);
}

exports.setTags = function(path, secret, args, response_callback) {
    var match_regex = new RegExp(args.regex);
    var tag = args.tag;
    
    var func = function(line) {
        var ret = line;
        if (line.match(match_regex)) {
            ret = setTag(line, tag);
            // ret = updateTimestamp(ret);
        }
        return ret;
    }
    modifyLines(path, secret, args, response_callback, func);
}

exports.removeTags = function(path, secret, args, response_callback) {
    var match_regex = new RegExp(args.regex);
    var tag = args.tag;
    
    var func = function(line) {
        var ret = line;
        if (line.match(match_regex)) {
            ret = removeTag(line, tag);
            // ret = updateTimestamp(ret);
        }
        return ret;
    }
    modifyLines(path, secret, args, response_callback, func);
}


if (module.id == require.main.id) {
    var s = 'Foo bar #modified(1001) #other(stuff) #baz';
    sys.puts(sys.inspect(updateTimestamp(s)));//, '#modified(yes)')));
}