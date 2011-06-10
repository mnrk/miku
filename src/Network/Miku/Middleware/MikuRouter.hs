{-# LANGUAGE OverloadedStrings #-}

module Network.Miku.Middleware.MikuRouter (miku_router) where

import Data.Maybe
import Hack2
import Hack2.Contrib.Utils
import Hack2.Contrib.Utils hiding (get, put)
import Air.Env
import Prelude ()
import Data.ByteString.UTF8 (fromString)
import qualified Prelude as P
import qualified Data.ByteString.Lazy.Char8 as B
import Data.ByteString.Lazy.Char8 (ByteString)

type RoutePathT a = (RequestMethod, ByteString, a)



miku_router :: ByteString -> (a -> Application) -> RoutePathT a -> Middleware
miku_router prefix runner route_path app = \env ->
  if route_path.match_route env.not
    then app env
    else do
      let (_, route_string, app_state) = route_path
          (_, params) = parse_params route_string (env.path_info) .fromJust
          
      runner app_state (merge_captured params env)
  where
    match_route env' (method, template, _) = 
      env'.request_method.is method 
        && env'.path_info.parse_params template .isJust
        
    merge_captured params env' = 
      env'.put_namespace prefix params 


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
      
-- copy from miku utils
put_namespace :: ByteString -> [(ByteString, ByteString)] -> Env -> Env
put_namespace x xs env = 
  let adds             = xs.map_fst (x +)
      new_headers      = adds.map fst
      new_hack_headers = 
        env.hackHeaders.reject (fst > belongs_to new_headers) ++ adds
  in
  env {hackHeaders = new_hack_headers}

