module MySQL.QueryResult
  ( class QueryResult
  , convert
  ) where

import Data.Foreign (F, Foreign)



class QueryResult a where
  convert :: Foreign -> F a
