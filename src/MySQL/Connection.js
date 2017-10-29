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
    return {};
  }
}

exports["_query'"] = function(opts, values, conn) {
  return function(onError, onSuccess) {
    conn.query(opts, values, function(e, r) {
      if (e) {
        onError(e);
      } else {
        onSuccess(r);
      }
    });
    return function(cancelError, onCancelerError, onCancelerSuccess) {
      onCancelerSuccess({});
    }
  }
}

exports.format = function(query) {
  return function(values) {
    return function(conn) {
      return conn.format(query, values);
    }
  }
}
