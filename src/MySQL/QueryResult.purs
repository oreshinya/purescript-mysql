module MySQL.QueryResult
  ( class QueryResult
  , convert
  ) where

import Prelude
import Control.Monad.Except (mapExcept)
import Data.Array ((..), zipWith, length)
import Data.Bifunctor (lmap)
import Data.Foreign (F, Foreign, ForeignError(ErrorAtIndex), readArray)
import Data.Foreign.Class (decode)
import Data.JSDate (JSDate, readDate)
import Data.Traversable (sequence)




class QueryResult a where
  convert :: Foreign -> F a



instance queryResultForeign :: QueryResult Foreign where
  convert = decode



instance queryResultString :: QueryResult String where
  convert = decode



instance queryResultChar :: QueryResult Char where
  convert = decode



instance queryResultBoolean :: QueryResult Boolean where
  convert = decode



instance queryResultNumber :: QueryResult Number where
  convert = decode



instance queryResultInt :: QueryResult Int where
  convert = decode



instance queryResultJSDate :: QueryResult JSDate where
  convert = readDate



instance queryResultArray :: QueryResult a => QueryResult (Array a) where
  convert = readArray >=> readElements where
    readElements :: Array Foreign -> F (Array a)
    readElements arr = sequence (zipWith readElement (0 .. length arr) arr)

    readElement :: Int -> Foreign -> F a
    readElement i value = mapExcept (lmap (map (ErrorAtIndex i))) (convert value)
