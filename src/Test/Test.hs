{-# LANGUAGE PackageImports #-}
{-# LANGUAGE OverloadedStrings #-}

import Control.Monad.Reader
import Hack2.Contrib.Response
-- import Hack2.Handler.SimpleServer
import Hack2.Handler.HappstackServer
import Hack2.Contrib.Utils (show_bytestring, s2l, l2s)

import Network.Miku
import Network.Miku.Engine
import Network.Miku.Utils
import Data.Maybe
import Air.Env hiding ((.))
import Prelude ((.))

import Hack2.Contrib.Request
import qualified Data.ByteString.Char8 as B
import qualified Data.ByteString.Lazy.Char8 as Lazy

import Hack2.Contrib.Middleware.SimpleAccessLogger



-- default on port 3000

main :: IO ()
main = do
  putStrLn "server started on port 3000..."
  
  run . miku - do
  
    
    before return
    after return

    middleware - simple_access_logger Nothing

    get "/bench" - do
      name <- ask ^ params ^ lookup "name" ^ fromMaybe "nobody"
      html ("<h1>" + s2l name + "</h1>")

    -- simple
    get "/hello"    (text "hello world")
  
    get "/debug"    (text . Lazy.pack . show =<< ask)
  
    -- io
    get "/cabal"    - text =<< io (Lazy.readFile "miku.cabal")

    -- route captures
    get "/say/:user/:message" - do
      text . Lazy.pack . show =<< captures

    -- html output
    get "/html"     (html "<html><body><p>miku power!</p></body></html>")


  
    -- default
    get "/" - do
      io . print =<< ask ^ url
      text . Lazy.pack . show =<< ask

    -- public serve, only allows /src
    public (Just ".") ["/src"]
  
    -- treat .hs extension as text/plain
    mime "hs" "text/plain"

