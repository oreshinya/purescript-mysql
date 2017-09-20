module MySQL.QueryResult where

import Prelude
import Data.Foreign (Foreign, F, readArray, readBoolean, readChar, readInt, readNumber, readString)
import Data.Foreign.NullOrUndefined (NullOrUndefined, readNullOrUndefined)
import Data.Traversable (sequence)



class QueryResult a where
  readResult :: Foreign -> F a

instance queryResultForeign :: QueryResult Foreign where
  readResult = pure

instance queryResultChar :: QueryResult Char where
  readResult = readChar

instance readNumber :: QueryResult Number where
  readResult = readNumber

instance readInt :: QueryResult Int where
  readResult = readInt

instance readString :: QueryResult String where
  readResult = readString

instance readBoolean :: QueryResult Boolean where
  readResult = readBoolean

instance readNullOrUndefined :: QueryResult a => QueryResult (NullOrUndefined a) where
  readResult = readNullOrUndefined readResult

instance readArray :: QueryResult a => QueryResult (Array a) where
  readResult = readElements <=< readArray
    where
      readElements xs = sequence $ readResult <$> xs
