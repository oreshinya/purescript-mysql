'use strict';

exports._begin = function(conn) {
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

exports._commit = function(conn) {
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

exports._rollback = function(conn) {
  return function(onError, onSuccess) {
    conn.rollback(function() {
      onSuccess({});
    });
    return function(cancelError, onCancelerError, onCancelerSuccess) {
      onCancelerSuccess({});
    }
  }
}
