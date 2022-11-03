'use strict';

export function _begin(conn) {
  return function(onError, onSuccess) {
    conn.beginTransaction(function(e) {
      if (e) {
        onError(e);
      } else {
        onSuccess({});
      }
    });
    return function(cancelError, onCancelerError, onCancelerSuccess) {
      onCancelerSuccess({});
    }
  }
}

export function _commit(conn) {
  return function(onError, onSuccess) {
    conn.commit(function(e){
      if (e) {
        onError(e);
      } else {
        onSuccess({});
      }
    });
    return function(cancelError, onCancelerError, onCancelerSuccess) {
      onCancelerSuccess({});
    }
  }
}

export function _rollback(conn) {
  return function(onError, onSuccess) {
    conn.rollback(function() {
      onSuccess({});
    });
    return function(cancelError, onCancelerError, onCancelerSuccess) {
      onCancelerSuccess({});
    }
  }
}
