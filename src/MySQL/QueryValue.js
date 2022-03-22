'use strict';

exports['null'] = null;

exports.match = function(a) {
  return function(b) {
    return a === b;
  }
}
