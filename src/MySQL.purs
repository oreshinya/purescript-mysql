module MySQL
  ( MYSQL
  , liftError
  ) where

import Prelude
import Control.Monad.Aff (Aff)
import Control.Monad.Eff (kind Effect)
import Control.Monad.Eff.Exception (error)
import Control.Monad.Error.Class (throwError)
import Data.Foreign (ForeignError)
import Data.List.Types (NonEmptyList)
import Data.Newtype (unwrap)
import Data.NonEmpty (head)



foreign import data MYSQL :: Effect



liftError :: forall e a. NonEmptyList ForeignError -> Aff e a
liftError = throwError <<< error <<< show <<< head <<< unwrap
