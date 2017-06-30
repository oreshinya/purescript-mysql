'use strict';

exports._begin = function(canceler, conn) {
  return function(success, error) {
    conn.beginTransaction(function(e) {
      if (e) {
        error(e);
      } else {
        success({});
      }
    });
    return canceler;
  }
}

exports._commit = function(canceler, conn) {
  return function(success, error) {
    conn.commit(function(e){
      if (e) {
        error(e);
      } else {
        success({});
      }
    });
    return canceler;
  }
}

exports._rollback = function(canceler, conn) {
  return function(success) {
    conn.rollback(function() {
      success({});
    });
    return canceler;
  }
}
