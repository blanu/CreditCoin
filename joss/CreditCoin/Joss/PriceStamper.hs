import System.IO
import qualified Data.ByteString as B
import Data.Serialize
import System.Environment (getArgs)
import Network.HTTP.Conduit (simpleHttp)

main :: IO()
main = do
    url = "http://api.bitcoincharts.com/v1/weighted_prices.json"
    result <- simpleHttp url
    putStrLn $ show result
