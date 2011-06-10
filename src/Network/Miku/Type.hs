module Network.Miku.Type where

import Control.Monad.Reader
import Control.Monad.State
import Data.Default
import Hack2
import Hack2.Contrib.Utils
import Network.Miku.Middleware.MikuRouter
import Data.ByteString.Lazy.Char8 (ByteString)

type RoutePathT a = (RequestMethod, ByteString, a)
type RoutePath    = RoutePathT AppMonad
type AppReader    = Env
type AppState     = Response
type AppMonadT     = ReaderT AppReader (StateT AppState IO)
type AppMonad      = AppMonadT ()

type RouterT a = ByteString -> (a -> Application) -> RoutePathT a -> Middleware
type Router    = RouterT AppMonad

data RouteConfig = RouteConfig
  {
    route_path :: RoutePath
  , router     :: Router
  }

data Miku = Miku
  {
    current_router  :: Router
  , routes          :: [RouteConfig]
  , middlewares     :: [Middleware]
  , mimes           :: [(ByteString, ByteString)]
  }


instance Default Miku where
  def = Miku 
    {
      current_router = miku_router
    , routes = def
    , middlewares = [dummy_middleware]
    , mimes = def
    }


type UnitT a = State Miku a
type Unit    = UnitT ()
