module MySQL.Milliseconds where

import Simple.JSON (class WriteForeign)

newtype Milliseconds = Milliseconds Number

derive newtype instance writeForeignMilliseconds :: WriteForeign Milliseconds
