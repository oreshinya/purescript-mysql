"use strict";

exports.unsafeLog = function (val) {
  return function() {
    console.log(val);
  }
};
