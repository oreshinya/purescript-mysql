module MySQL where

import Prelude
import Control.Monad.Aff (Aff, Canceler, nonCanceler)
import Control.Monad.Eff (Eff, kind Effect)
import Control.Monad.Eff.Exception (error)
import Control.Monad.Error.Class (throwError)
import Control.Monad.Except (runExcept)
import Data.Either (either)
import Data.Foreign (Foreign, ForeignError)
import Data.Foreign.Class (class Decode, decode)
import Data.Function.Uncurried (Fn4, runFn4)
import Data.List.Types (NonEmptyList)
import Data.Newtype (unwrap)
import Data.NonEmpty (head)
import Data.Traversable (sequence)
import MySQL.QueryValue (QueryValue)



type ConnectionInfo =
    { host :: String
    , port :: Int
    , user :: String
    , password :: String
    , database :: String
    , charset :: String
    , timezone :: String
    , connectTimeout :: Int
    , debug :: Boolean
    , trace :: Boolean
    }

type QueryOptions =
  { sql :: String
  , nestTables :: Boolean
  }

foreign import data Connection :: Type

foreign import data MYSQL :: Effect



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
  , debug: false
  , trace: true
  }



queryWithOptions :: forall e a.
                    Decode a =>
                    QueryOptions ->
                    Array QueryValue ->
                    Connection ->
                    Aff (mysql :: MYSQL | e) (Array a)
queryWithOptions opts vs conn = do
  rows <- runFn4 _query nonCanceler opts vs conn
  either liftError pure $ runExcept $ sequence $ decode <$> rows



queryWithOptions_ :: forall e a.
                     Decode a =>
                     QueryOptions ->
                     Connection ->
                     Aff (mysql :: MYSQL | e) (Array a)
queryWithOptions_ opts = queryWithOptions opts []



query :: forall e a.
         Decode a =>
         String ->
         Array QueryValue ->
         Connection ->
         Aff (mysql :: MYSQL | e) (Array a)
query sql = queryWithOptions { sql, nestTables: false }



query_ :: forall e a.
          Decode a =>
          String ->
          Connection ->
          Aff (mysql :: MYSQL | e) (Array a)
query_ sql = query sql []



execute :: forall e.
           String ->
           Array QueryValue ->
           Connection ->
           Aff (mysql :: MYSQL | e) Unit
execute sql vs conn =
  void $ runFn4 _query nonCanceler { sql, nestTables: false } vs conn



execute_ :: forall e.
            String ->
            Connection ->
            Aff (mysql :: MYSQL | e) Unit
execute_ sql = execute sql []



liftError :: forall e a. NonEmptyList ForeignError -> Aff e a
liftError = throwError <<< error <<< show <<< head <<< unwrap



foreign import createConnection :: forall e.
                                   ConnectionInfo ->
                                   Eff (mysql :: MYSQL | e) Connection



foreign import closeConnection :: forall e.
                                  Connection ->
                                  Eff (mysql :: MYSQL | e) Unit



foreign import _query :: forall e. Fn4 (Canceler (mysql :: MYSQL | e)) QueryOptions (Array QueryValue) Connection (Aff (mysql :: MYSQL | e) (Array Foreign))
