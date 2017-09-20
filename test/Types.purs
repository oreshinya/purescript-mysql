module Test.Types where

import Prelude

import Data.Foreign.Class (class Decode, decode)
import Data.Foreign.Generic (defaultOptions, genericDecode)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import MySQL.QueryResult (class QueryResult)


newtype User
  = User
    { id :: String
    , name :: String
    , createdAt :: String
    , updatedAt :: String
    }

derive instance genericUser :: Generic User _

instance decodeUser :: Decode User where
  decode = genericDecode $ defaultOptions { unwrapSingleConstructors = true }

instance queryResultUser :: QueryResult User where
  readResult = decode

instance showUser :: Show User where
  show = genericShow
