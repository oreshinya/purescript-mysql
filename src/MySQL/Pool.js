'use strict';

const mysql = require('mysql');

exports._createPool = function(connectionInfo, poolInfo) {
  return function() {
    const opts = Object.assign(
      {},
      connectionInfo,
      poolInfo
    );
    return mysql.createPool(opts);
  }
}

exports.closePool = function(pool) {
  return function() {
    pool.end();
    return {};
  }
}

exports._getConnection = function(pool) {
  return function(onError, onSuccess) {
    pool.getConnection(function(e, conn) {
      if (e) {
        onError(e);
      } else {
        onSuccess(conn);
      }
    });
    return function(cancelError, onCancelerError, onCancelerSuccess) {
      onCancelerSuccess({});
    }
  }
}

exports._releaseConnection = function(conn) {
  return function(onError, onSuccess) {
    conn.release();
    onSuccess({});
    return function(cancelError, onCancelerError, onCancelerSuccess) {
      onCancelerSuccess({});
    }
  }
}
