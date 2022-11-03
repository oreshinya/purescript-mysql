'use strict';

import mysql from "mysql";

export function createConnection(connectionInfo) {
  return function() {
    return mysql.createConnection(connectionInfo);
  }
}

export function closeConnection(connection) {
  return function() {
    connection.end();
    return {};
  }
}

export function queryImpl(opts, values, conn) {
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

export function format(query) {
  return function(values) {
    return function(conn) {
      return function() {
        return conn.format(query, values);
      }
    }
  }
}
