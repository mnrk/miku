module Network.Miku.DSL where

import Control.Monad.Reader
import Control.Monad.State
import Hack2
import Hack2.Contrib.Middleware.Censor
import Hack2.Contrib.Middleware.Config
import Hack2.Contrib.Middleware.IOConfig
import Hack2.Contrib.Middleware.Static
import Hack2.Contrib.Response
import Hack2.Contrib.Constants
import Air
import Network.Miku.Config
import Network.Miku.Engine
import Network.Miku.Type
import Network.Miku.Utils
import Prelude hiding ((.), (>), (^), (-))
import qualified Control.Monad.State as State
import Data.ByteString.Lazy.Char8 (ByteString)

import Air.Data.Record.SimpleLabel hiding (get)

app :: Application -> AppMonad
app f = ask >>= (f > io) >>= State.put

router :: Router -> MikuMonad
router = setM __current_router

get, put, post, delete :: ByteString -> AppMonad -> MikuMonad
get    = add_route GET
put    = add_route PUT
post   = add_route POST
delete = add_route DELETE


middleware :: Middleware -> MikuMonad
middleware x = modM __middlewares - insert_last x

before :: (Env -> IO Env) -> MikuMonad
before = ioconfig > middleware

after :: (Response -> IO Response) -> MikuMonad
after = censor > middleware

mime :: ByteString -> ByteString -> MikuMonad
mime k v = modM __mimes - insert_last (k,v)

public :: Maybe ByteString -> [ByteString] -> MikuMonad
public r xs = middleware - static r xs

io :: (MonadIO m) => IO a -> m a
io = liftIO

text :: ByteString -> AppMonad
text x = do
  update - set_content_type _TextPlain
  update - set_body x

html :: ByteString -> AppMonad
html x = do
  update - set_content_type _TextHtml
  update - set_body x


captures :: AppMonadT [(ByteString, ByteString)]
captures = ask ^ namespace miku_captures
