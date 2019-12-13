module MySQL.Pool
  ( PoolInfo
  , Pool
  , defaultPoolInfo
  , createPool
  , closePool
  , getConnection
  , releaseConnection
  , withPool
  ) where

import Prelude

import Control.Monad.Error.Class (throwError)
import Data.Either (Either(..))
import Data.Function.Uncurried (Fn2, runFn2)
import Data.Time.Duration (Milliseconds(..))
import Effect (Effect)
import Effect.Aff (Aff, attempt)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import MySQL.Connection (Connection, ConnectionInfo)

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
createPool cinfo pinfo = runFn2 _createPool cinfo pinfo

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
  r <- attempt $ handler conn
  releaseConnection conn
  case r of
    Left err -> throwError err
    Right r' -> pure r'

foreign import _createPool :: Fn2 ConnectionInfo PoolInfo (Effect Pool)

foreign import closePool :: Pool -> Effect Unit

foreign import _getConnection :: Pool -> EffectFnAff Connection

foreign import _releaseConnection :: Connection -> EffectFnAff Unit
