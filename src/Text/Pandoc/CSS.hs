module Text.Pandoc.CSS ( foldOrElse,
                         pickStyleAttrProps
                       )
where

import Text.Pandoc.Shared (trim)
import Text.Parsec
import Text.Parsec.String

ruleParser :: Parser (String, String)
ruleParser = do
    p <- many1 (noneOf ":")  <* char ':'
    v <- many1 (noneOf ":;") <* char ';' <* spaces
    return (trim p, trim v)

styleAttrParser :: Parser [(String, String)]
styleAttrParser = many1 ruleParser

orElse :: Eq a => a -> a -> a -> a
orElse v x y = if v == x then y else x

foldOrElse :: Eq a => a -> [a] -> a
foldOrElse v xs = foldr (orElse v) v xs

eitherToMaybe :: Either a b -> Maybe b
eitherToMaybe (Right x) = Just x
eitherToMaybe _ = Nothing

pickStyleAttrProps :: [String] -> String -> Maybe String
pickStyleAttrProps lookupProps styleAttr = do
    styles <- eitherToMaybe $ parse styleAttrParser "" styleAttr
    foldOrElse Nothing $ map (flip lookup styles) lookupProps
