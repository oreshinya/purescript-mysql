'use strict';

const nullImpl = null;
export { nullImpl as null }

export function match(a) {
  return function(b) {
    return a === b;
  }
}
