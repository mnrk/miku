{-# LANGUAGE NamedFieldPuns #-}

module Network.Miku.Engine where

import Control.Monad.Reader hiding (join)
import Control.Monad.State hiding (join)
import Data.Default
import Hack2
import Hack2.Contrib.Middleware.UserMime
import Hack2.Contrib.Middleware.NotFound
import Hack2.Contrib.Utils hiding (get, put)
import Air.Env
import Network.Miku.Config
import Network.Miku.Middleware.MikuRouter ()
import Network.Miku.Type
import Network.Miku.Utils
import Prelude ()
import Data.ByteString.Lazy.Char8 (ByteString)

run_app :: AppMonad -> Application
run_app unit = \env -> runReaderT unit env .flip execStateT def {status = 200}

miku :: MikuMonad -> Application
miku unit = run unit not_found_app
  where
    not_found_app = not_found dummy_app
    run_router  router_config = (router_config.router) miku_captures run_app (router_config.route_path)
    
    run :: MikuMonad -> Middleware
    run unit' = 
      let miku_state    = execState unit' def
          router_configs = miku_state.routes
          route         = router_configs.map run_router  .use
          mime_filter   = user_mime (miku_state.mimes)
          stack         = miku_state.middlewares.use
          pre           = pre_installed_middlewares.use
      in
      use [pre, mime_filter, stack, route]

add_router_config :: RouterConfig -> MikuState -> MikuState
add_router_config r s = let xs = s.routes in s {routes = xs.insert_last r}

add_route :: RequestMethod -> ByteString -> AppMonad -> MikuMonad
add_route r s u = do
  c <- get ^ current_router
  update - add_router_config RouterConfig { route_path = (r, s, u), router = c }

set_router :: Router -> MikuState -> MikuState
set_router r x = x { current_router = r }

add_middleware :: Middleware -> MikuState -> MikuState
add_middleware x s = 
  let xs = s.middlewares in s {middlewares = xs.insert_last x}

add_mime :: ByteString -> ByteString -> MikuState -> MikuState
add_mime k v s = let xs = s.mimes in s {mimes = xs.insert_last (k, v)}


