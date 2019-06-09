module MySQL.Pool
  ( PoolInfo
  , Pool
  , defaultPoolInfo
  , createPool
  , closePool
  , withPool
  ) where

import Prelude

import Data.Function.Uncurried (Fn2, runFn2)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Foreign (Foreign)
import MySQL.Connection (ConnectionInfo, Connection)
import MySQL.Milliseconds (Milliseconds(..))
import Simple.JSON (write)

type PoolInfo =
  { acquireTimeout :: Milliseconds
  , waitForConnections :: Boolean
  , connectionLimit :: Int
  , queueLimit :: Int
  }

foreign import data Pool :: Type

defaultPoolInfo :: PoolInfo
defaultPoolInfo =
  { acquireTimeout: Milliseconds 10000.0
  , waitForConnections: true
  , connectionLimit: 10
  , queueLimit: 0
  }

createPool :: ConnectionInfo -> PoolInfo -> Effect Pool
createPool cinfo pinfo =
  runFn2 _createPool
    (write cinfo)
    (write pinfo)

getConnection :: Pool -> Aff Connection
getConnection = fromEffectFnAff <<< _getConnection

releaseConnection :: Connection -> Aff Unit
releaseConnection = fromEffectFnAff <<< _releaseConnection

withPool
  :: forall a
   . (Connection -> Aff a)
  -> Pool
  -> Aff a
withPool handler pool = do
  conn <- getConnection pool
  r <- handler conn
  releaseConnection conn
  pure r

foreign import _createPool :: Fn2 Foreign Foreign (Effect Pool)

foreign import closePool :: Pool -> Effect Unit

foreign import _getConnection :: Pool -> EffectFnAff Connection

foreign import _releaseConnection :: Connection -> EffectFnAff Unit
