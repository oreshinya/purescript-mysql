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

exports._getConnection = function(canceler, pool) {
  return function(success, error) {
    pool.getConnection(function(e, conn) {
      if (e) {
        error(e);
      } else {
        success(conn);
      }
    });
    return canceler;
  }
}

exports._releaseConnection = function(canceler, conn) {
  return function(success) {
    conn.release();
    success({});
    return canceler;
  }
}
