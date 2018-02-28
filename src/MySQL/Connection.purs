module MySQL.Connection
  ( ConnectionInfo
  , QueryOptions
  , Connection
  , defaultConnectionInfo
  , queryWithOptions
  , queryWithOptions_
  , query
  , query_
  , execute
  , execute_
  , format
  , createConnection
  , closeConnection
  ) where

import Prelude

import Control.Monad.Aff (Aff)
import Control.Monad.Aff.Compat (EffFnAff, fromEffFnAff)
import Control.Monad.Eff (Eff, kind Effect)
import Control.Monad.Except (runExcept)
import Data.Either (either)
import Data.Foreign (Foreign)
import Data.Function.Uncurried (Fn3, runFn3)
import MySQL (MYSQL, liftError)
import MySQL.QueryValue (QueryValue)
import Simple.JSON (class ReadForeign, read)



type ConnectionInfo =
    { host :: String
    , port :: Int
    , user :: String
    , password :: String
    , database :: String
    , charset :: String
    , timezone :: String
    , connectTimeout :: Int
    , dateStrings :: Boolean
    , debug :: Boolean
    , trace :: Boolean
    , multipleStatements :: Boolean
    }

type QueryOptions =
  { sql :: String
  , nestTables :: Boolean
  }

foreign import data Connection :: Type



defaultConnectionInfo :: ConnectionInfo
defaultConnectionInfo =
  { host: "localhost"
  , port: 3306
  , user: "root"
  , password: ""
  , database: ""
  , charset: "UTF8_GENERAL_CI"
  , timezone: "Z"
  , connectTimeout: 10000
  , dateStrings: true
  , debug: false
  , trace: true
  , multipleStatements : false
  }



queryWithOptions
  :: forall e a
   . ReadForeign a
  => QueryOptions
  -> Array QueryValue
  -> Connection
  -> Aff (mysql :: MYSQL | e) (Array a)
queryWithOptions opts vs conn = do
  rows <- _query opts vs conn
  either liftError pure $ runExcept $ read rows



queryWithOptions_
  :: forall e a
   . ReadForeign a
  => QueryOptions
  -> Connection
  -> Aff (mysql :: MYSQL | e) (Array a)
queryWithOptions_ opts = queryWithOptions opts []



query
  :: forall e a
   . ReadForeign a
  => String
  -> Array QueryValue
  -> Connection
  -> Aff (mysql :: MYSQL | e) (Array a)
query sql = queryWithOptions { sql, nestTables: false }



query_
  :: forall e a
   . ReadForeign a
  => String
  -> Connection
  -> Aff (mysql :: MYSQL | e) (Array a)
query_ sql = query sql []



execute
  :: forall e
   . String
  -> Array QueryValue
  -> Connection
  -> Aff (mysql :: MYSQL | e) Unit
execute sql vs conn =
  void $ _query { sql, nestTables: false } vs conn



execute_
  :: forall e
   . String
  -> Connection
  -> Aff (mysql :: MYSQL | e) Unit
execute_ sql = execute sql []



_query
  :: forall e
   . QueryOptions
  -> Array QueryValue
  -> Connection
  -> Aff (mysql :: MYSQL | e) Foreign
_query opts values conn = fromEffFnAff $ runFn3 _query' opts values conn



foreign import createConnection
  :: forall e
   . ConnectionInfo
  -> Eff (mysql :: MYSQL | e) Connection



foreign import closeConnection
  :: forall e
   . Connection
  -> Eff (mysql :: MYSQL | e) Unit



foreign import _query'
  :: forall e
   . Fn3 QueryOptions (Array QueryValue) Connection (EffFnAff (mysql :: MYSQL | e) Foreign)



foreign import format :: String -> (Array QueryValue) -> Connection -> String
