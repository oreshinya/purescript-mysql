module MySQL.QueryValue
  ( QueryValue
  , class Queryable
  , toQueryValue
  , match
  ) where

import Prelude

import Data.JSDate (JSDate)
import Data.Maybe (Maybe(..))
import Unsafe.Coerce (unsafeCoerce)

foreign import data QueryValue :: Type

class Queryable a where
  toQueryValue :: a -> QueryValue

instance queryableQueryValue :: Queryable QueryValue where
  toQueryValue = identity

instance queryableString :: Queryable String where
  toQueryValue = unsafeCoerce

instance queryableNumber :: Queryable Number where
  toQueryValue = unsafeCoerce

instance queryableInt :: Queryable Int where
  toQueryValue = unsafeCoerce

instance queryableMaybe :: Queryable a => Queryable (Maybe a) where
  toQueryValue Nothing = null
  toQueryValue (Just a) = toQueryValue a

instance queryableJSDate :: Queryable JSDate where
  toQueryValue = unsafeCoerce

instance queryableArray :: Queryable a => Queryable (Array a) where
  toQueryValue xs = unsafeCoerce $ toQueryValue <$> xs

foreign import null :: QueryValue

-- | Check if they are same reference.
foreign import match :: QueryValue -> QueryValue -> Boolean
