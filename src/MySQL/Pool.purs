module MySQL.Pool
  ( PoolInfo
  , Pool
  , defaultPoolInfo
  , createPool
  , closePool
  , withPool
  ) where

import Prelude

import Control.Monad.Aff (Aff)
import Control.Monad.Aff.Compat (EffFnAff, fromEffFnAff)
import Control.Monad.Eff (Eff)
import Data.Function.Uncurried (Fn2, runFn2)
import MySQL (MYSQL)
import MySQL.Connection (ConnectionInfo, Connection)



type PoolInfo =
  { acquireTimeout :: Int
  , waitForConnections :: Boolean
  , connectionLimit :: Int
  , queueLimit :: Int
  }

foreign import data Pool :: Type



defaultPoolInfo :: PoolInfo
defaultPoolInfo =
  { acquireTimeout: 10000
  , waitForConnections: true
  , connectionLimit: 10
  , queueLimit: 0
  }



createPool :: forall e. ConnectionInfo -> PoolInfo -> Eff (mysql :: MYSQL | e) Pool
createPool = runFn2 _createPool



getConnection :: forall e. Pool -> Aff (mysql :: MYSQL | e) Connection
getConnection = fromEffFnAff <<< _getConnection



releaseConnection :: forall e. Connection -> Aff (mysql :: MYSQL | e) Unit
releaseConnection = fromEffFnAff <<< _releaseConnection



withPool
  :: forall e a
   . (Connection -> Aff (mysql :: MYSQL | e) a)
  -> Pool
  -> Aff (mysql :: MYSQL | e) a
withPool handler pool = do
  conn <- getConnection pool
  r <- handler conn
  releaseConnection conn
  pure r



foreign import _createPool :: forall e. Fn2 ConnectionInfo PoolInfo (Eff (mysql :: MYSQL | e) Pool)



foreign import closePool :: forall e. Pool -> Eff (mysql :: MYSQL | e) Unit



foreign import _getConnection :: forall e. Pool -> EffFnAff (mysql :: MYSQL | e) Connection



foreign import _releaseConnection :: forall e. Connection -> EffFnAff (mysql :: MYSQL | e) Unit
