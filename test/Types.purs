module Test.Types where

import Prelude
import Data.Foreign.Class (class Decode)
import Data.Foreign.Generic (defaultOptions, genericDecode)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)


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

instance showUser :: Show User where
  show = genericShow
