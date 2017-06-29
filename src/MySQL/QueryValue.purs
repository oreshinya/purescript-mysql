module MySQL.QueryValue
  ( QueryValue
  , class Queryable
  , toQueryValue
  ) where

import Data.Maybe (Maybe(..))
import Data.JSDate (JSDate)
import Unsafe.Coerce (unsafeCoerce)



foreign import data QueryValue :: Type



class Queryable a where
  toQueryValue :: a -> QueryValue



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



foreign import null :: QueryValue
