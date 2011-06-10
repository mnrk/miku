{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}


module Network.Miku.Engine where

import Control.Monad.Reader hiding (join)
import Control.Monad.State hiding (join)
import Data.Default
import Hack2
import Hack2.Contrib.Middleware.UserMime
import Hack2.Contrib.Middleware.NotFound
import Hack2.Contrib.Utils hiding (get, put)
import Air.Env hiding (mod)
import Network.Miku.Config
import Network.Miku.Type
import Network.Miku.Utils
import Prelude ()
import Data.ByteString.Lazy.Char8 (ByteString)
import qualified Data.ByteString.Lazy.Char8 as B
import qualified Prelude as P
import Air.Data.Record.SimpleLabel hiding (get)
import Data.Maybe




miku :: MikuMonad -> Application
miku miku_monad = miku_middleware miku_monad (not_found dummy_app)

    
miku_middleware :: MikuMonad -> Middleware
miku_middleware miku_monad = 
  
  let miku_state                  = execState miku_monad def
      mime_filter                 = user_mime (miku_state.mimes)
      miku_middlewares            = miku_state.middlewares.use
      pre_installed_middleware    = pre_installed_middlewares.use
  in
  
  use [pre_installed_middleware, mime_filter, miku_middlewares]
  

miku_router :: RequestMethod -> ByteString -> AppMonad -> Middleware
miku_router route_method route_string app_monad app = \env ->
  if env.request_method == route_method 
    then
      case env.path_info.parse_params route_string of
        Nothing -> app env
        Just (_, params) -> 
          let miku_app = run_app - local (put_namespace miku_captures params) app_monad 
          in
          miku_app env
    
    else
      app env
  
  
  where
    
    run_app_monad :: AppMonad -> Application
    run_app_monad app_monad = \env -> runReaderT app_monad env .flip execStateT def {status = 200}
    

parse_params :: ByteString -> ByteString -> Maybe (ByteString, [(ByteString, ByteString)])
parse_params "" ""  = Just ("", [])
parse_params "" _   = Nothing
parse_params "/" "" = Nothing
parse_params "/" _  = Just ("/", [])

parse_params t s = 
  let template_tokens = t.B.split '/'
      url_tokens      = s.B.split '/'
  in
  if url_tokens.length P.< template_tokens.length
    then Nothing
    else 
      let rs = zipWith capture template_tokens url_tokens
      in
      if rs.all isJust
        then 
          let token_length = template_tokens.length
              location     = B.pack - "/" / (B.unpack - url_tokens.take token_length .B.intercalate "/")
          in
          Just - (location, rs.catMaybes.catMaybes)
        else Nothing
  
  where
    capture x y 
      | x.B.unpack.starts_with ":" = Just - Just (x.B.tail, y)
      | x == y = Just Nothing
      | otherwise = Nothing
