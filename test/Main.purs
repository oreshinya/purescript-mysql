module Test.Main where

import Prelude

import Control.Monad.Aff (Aff, runAff)
import Control.Monad.Aff.Console as AC
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Eff.Exception (EXCEPTION, message)
import MySQL (MYSQL)
import MySQL.Connection (Connection, ConnectionInfo, defaultConnectionInfo, queryWithOptions, query_, execute_, format)
import MySQL.Pool (closePool, createPool, defaultPoolInfo, withPool)
import MySQL.QueryValue (toQueryValue)
import MySQL.Transaction (withTransaction)
import Test.Types (User)



ident :: String
ident = "53f49285-a00e-46a6-b445-d25c49c228ba"

ident2 :: String
ident2 = "192fea9b-c657-4420-af76-718702bd2846"

ident3 :: String
ident3 = "649d2782-e161-4170-a1d7-cf65afdfc985"

ident4 :: String
ident4 = "45572d57-d4e5-411b-b6b6-ab6a1a8df5f9"



connectionInfo :: ConnectionInfo
connectionInfo = defaultConnectionInfo { database = "purescript_mysql", debug = true }



main :: forall e. Eff (console :: CONSOLE, mysql :: MYSQL, exception :: EXCEPTION | e) Unit
main = do
  pool <- createPool connectionInfo defaultPoolInfo
  void $ runAff (error pool) (success pool) do
    flip withPool pool \conn -> do
      execute_ "TRUNCATE TABLE users" conn
      execute_ ("INSERT INTO users (id, name) VALUES ('" <> ident <> "', 'User 1')") conn
      void $ selectUsers conn
      flip withTransaction conn \c -> do
        execute_ ("INSERT INTO users (id, name) VALUES ('" <> ident2 <> "', 'User 2')") conn
        execute_ ("INSERT INTO users (id, name) VALUES ('" <> ident3 <> "', 'User 3')") conn
      users <- selectUsers' conn
      --flip withTransaction conn \c -> do
      --  execute_ ("INSERT INTO users (id, name) VALUES ('" <> ident4 <> "', 'User 4')") conn
      --  execute_ ("INSERT INTO users (id, name) VALUES ('" <> ident <> "', 'User 5')") conn
      AC.log $ format "INSERT INTO users (id, name) VALUES (?, ?)" [ toQueryValue ident, toQueryValue "User 6"] conn
      pure users
    where
      opts =
        { sql: "SELECT * FROM users WHERE id = ?"
        , nestTables: false
        }

      selectUsers :: forall eff. Connection -> Aff (mysql :: MYSQL | eff) (Array User)
      selectUsers = queryWithOptions opts [ toQueryValue ident ]

      selectUsers' :: forall eff. Connection -> Aff (mysql :: MYSQL | eff) (Array User)
      selectUsers' = query_ "SELECT * FROM users"

      error pool err = do
        log ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
        log $ message err
        closePool pool

      success pool users = do
        log $ show users
        closePool pool
