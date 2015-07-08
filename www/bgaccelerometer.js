var exec = require('cordova/exec');

exports.setConfig = function(arg0,arg1, success, error) {
    exec(success, error, "bgaccelerometer", "setConfig", [arg0,arg1]);
};

exports.startRecording = function(success, error) {
    exec(success, error, "bgaccelerometer", "startRecording", []);
};

exports.stopRecording = function( success, error) {
    exec(success, error, "bgaccelerometer", "stopRecording", []);
};

exports.getData = function( success, error) {
    exec(success, error, "bgaccelerometer", "getData", []);
};

exports.clearData = function( success, error) {
    exec(success, error, "bgaccelerometer", "clearData", []);
};
exports.getConfig = function( success, error) {
    exec(success, error, "bgaccelerometer", "getConfig", []);
};
