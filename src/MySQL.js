'use strict';

const mysql = require('mysql');

exports.createConnection = function(connectionInfo) {
  return function() {
    return mysql.createConnection(connectionInfo);
  }
}

exports.closeConnection = function(connection) {
  return function() {
    connection.end();
  }
}

exports._query = function(canceler, opts, values, conn) {
  return function(success, error) {
    conn.query(opts, values, function(e, r) {
      if (e) {
        error(e);
      } else {
        success(r);
      }
    });
    return canceler;
  }
}
