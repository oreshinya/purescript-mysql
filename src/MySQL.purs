module MySQL where

import Control.Monad.Eff (kind Effect)



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

type PoolInfo =
  { acquireTimeout :: Int
  , waitForConnections :: Boolean
  , connectionLimit :: Int
  , queueLimit :: Int
  }

foreign import data Connection :: Type

foreign import data Pool :: Type

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



defaultPoolInfo :: PoolInfo
defaultPoolInfo =
  { acquireTimeout: 10000
  , waitForConnections: true
  , connectionLimit: 10
  , queueLimit: 0
  }
