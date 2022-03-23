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
  , _query
  , format
  , createConnection
  , closeConnection
  ) where

import Prelude

import Data.Either (either)
import Data.Function.Uncurried (Fn3, runFn3)
import Data.Time.Duration (Milliseconds(..))
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Foreign (Foreign)
import MySQL.Internal (liftError)
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
    , connectTimeout :: Milliseconds
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
  , connectTimeout: Milliseconds 10000.0
  , dateStrings: true
  , debug: false
  , trace: true
  , multipleStatements : false
  }

queryWithOptions
  :: forall a
   . ReadForeign a
  => QueryOptions
  -> Array QueryValue
  -> Connection
  -> Aff a
queryWithOptions opts vs conn = do
  rows <- _query opts vs conn
  either liftError pure  $ read rows

queryWithOptions_
  :: forall a
   . ReadForeign a
  => QueryOptions
  -> Connection
  -> Aff a
queryWithOptions_ opts = queryWithOptions opts []

query
  :: forall a
   . ReadForeign a
  => String
  -> Array QueryValue
  -> Connection
  -> Aff a
query sql = queryWithOptions { sql, nestTables: false }

query_
  :: forall a
   . ReadForeign a
  => String
  -> Connection
  -> Aff a
query_ sql = query sql []

execute
  :: String
  -> Array QueryValue
  -> Connection
  -> Aff Unit
execute sql vs conn =
  void $ _query { sql, nestTables: false } vs conn

execute_
  :: String
  -> Connection
  -> Aff Unit
execute_ sql = execute sql []

_query
  :: QueryOptions
  -> Array QueryValue
  -> Connection
  -> Aff Foreign
_query opts values conn = fromEffectFnAff $ runFn3 _queryImpl opts values conn

foreign import createConnection
  :: ConnectionInfo
  -> Effect Connection

foreign import closeConnection
  :: Connection
  -> Effect Unit

foreign import _queryImpl
  :: Fn3 QueryOptions (Array QueryValue) Connection (EffectFnAff Foreign)

foreign import format
  :: String
  -> Array QueryValue
  -> Connection
  -> Effect String
