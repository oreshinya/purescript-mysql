'use strict';

import mysql from "mysql";

export function _createPool(connectionInfo, poolInfo) {
  return function() {
    const opts = Object.assign(
      {},
      connectionInfo,
      poolInfo
    );
    return mysql.createPool(opts);
  }
}

export function closePool(pool) {
  return function() {
    pool.end();
    return {};
  }
}

export function _getConnection(pool) {
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

export function _releaseConnection(conn) {
  return function(onError, onSuccess) {
    conn.release();
    onSuccess({});
    return function(cancelError, onCancelerError, onCancelerSuccess) {
      onCancelerSuccess({});
    }
  }
}
