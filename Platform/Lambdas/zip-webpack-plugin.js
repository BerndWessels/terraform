/*
 MIT License http://www.opensource.org/licenses/mit-license.php
 Author Tobias Koppers @sokra
 */
var path = require('path');
var async = require("async");
var url = require('url');
var JSZip = require('jszip');

var RawSource = require("webpack-sources/lib/RawSource");

function CompressionPlugin(options) {
    options = options || {};
}
module.exports = CompressionPlugin;

CompressionPlugin.prototype.apply = function(compiler) {
    compiler.plugin("this-compilation", function(compilation) {
        compilation.plugin("optimize-assets", function(assets, callback) {
            async.forEach(Object.keys(assets), function(file, callback) {
                var asset = assets[file];
                var content = asset.source();
                if(!Buffer.isBuffer(content))
                    content = new Buffer(content, "utf-8");
                var parse = url.parse(file);
                let zip = new JSZip();
                zip.file(path.basename(compilation.options.entry[Object.keys(compilation.options.entry)[0]]), content);
                zip.generateAsync({type: 'nodebuffer'}).then(body => {
                    assets[path.join(path.dirname(parse.pathname), path.basename(parse.pathname, '.js') + '.zip')] = new RawSource(body);
                    callback();
                });
            }.bind(this), callback);
        }.bind(this));
    }.bind(this));
};
