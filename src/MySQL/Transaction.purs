module MySQL.Transaction
  ( withTransaction
  ) where

import Prelude

import Control.Monad.Aff (Aff, attempt)
import Control.Monad.Aff.Compat (EffFnAff, fromEffFnAff)
import Control.Monad.Error.Class (throwError)
import Data.Either (Either(..))
import MySQL (MYSQL)
import MySQL.Connection (Connection)



withTransaction
  :: forall e a
   . (Connection -> Aff (mysql :: MYSQL | e) a)
  -> Connection
  -> Aff (mysql :: MYSQL | e) a
withTransaction handler conn = do
  begin conn
  r <- attempt $ handler conn
  case r of
    Left e -> do
      rollback conn
      throwError e
    Right r' -> do
      commit conn
      pure r'



begin :: forall e. Connection -> Aff (mysql :: MYSQL | e) Unit
begin = fromEffFnAff <<< _begin



commit :: forall e. Connection -> Aff (mysql :: MYSQL | e) Unit
commit = fromEffFnAff <<< _commit



rollback :: forall e. Connection -> Aff (mysql :: MYSQL | e) Unit
rollback = fromEffFnAff <<< _rollback



foreign import _begin :: forall e. Connection  -> EffFnAff (mysql :: MYSQL | e) Unit



foreign import _commit :: forall e. Connection -> EffFnAff (mysql :: MYSQL | e) Unit



foreign import _rollback :: forall e. Connection -> EffFnAff (mysql :: MYSQL | e) Unit
