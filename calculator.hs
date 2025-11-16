{-
  A basic calculator for arithmetic expressions
  Based on the example in Chapter 8 of "Programming in Haskell"
  by Graham Hutton.

  Pedro Vasconcelos, 2025
-}
module Main where

import Parsing
import Data.Char

--
-- a data type for expressions
-- made up from integer numbers, + and *
--
data Expr = Num Integer
          | Var String
          | Add Expr Expr
          | Sub Expr Expr
          | Mul Expr Expr
          | Div Expr Expr
          | Mod Expr Expr
          deriving Show

data Command = Expr Expr 
             | Assign String Expr
            deriving Show

type Env = [( String , Integer )]

-- a recursive evaluator for expressions
--
eval :: Env -> Expr -> Integer
eval _ (Num n) = n
eval env (Add e1 e2) = eval env e1 + eval env e2
eval env (Sub e1 e2) = eval env e1 - eval env e2
eval env (Mul e1 e2) = eval env e1 * eval env e2
eval env (Div e1 e2) = eval env e1 `div` eval env e2
eval env (Mod e1 e2) = eval env e1 `mod` eval env e2
eval env (Var x) 
    = case lookup x env of
        Just b -> b
        Nothing -> error "undefined variable"


evalCommand :: Env -> Command -> (Integer, Env)
evalCommand env (Expr e) = (eval env e, env)
evalCommand env (Assign var e)  = (res, env1)
    where
        res = eval env e
        env1 = (var,res) : filter (\(x,_) -> x /= var) env  


-- | a parser for expressions
-- Grammar rules:
--
-- expr ::= term exprCont
-- exprCont ::= '+' term exprCont | epsilon

-- term ::= factor termCont
-- termCont ::= '*' factor termCont | epsilon

-- factor ::= natural | '(' expr ')'

expr :: Parser Expr
expr = do t <- term
          exprCont t

exprCont :: Expr -> Parser Expr
exprCont acc = do 
        char '+'
        t <- term
        exprCont (Add acc t)
    <|> do 
        char '-'
        t <- term 
        exprCont (Sub acc t)
    <|> return acc
              
term :: Parser Expr
term = do f <- factor
          termCont f

termCont :: Expr -> Parser Expr
termCont acc = do 
        char '*'
        f <- factor  
        termCont (Mul acc f)
    <|> do 
        char '/'
        f <- factor 
        termCont (Div acc f)
    <|> do 
        char '%'
        f <- factor
        termCont (Mod acc f)
    <|> return acc

factor :: Parser Expr
factor = do n <- natural
            return (Num n)
        <|> do 
            v <- variable
            return (Var v)
        <|> do 
            char '('
            e <- expr
            char ')'
            return e
             

natural :: Parser Integer
natural = do xs <- many1 (satisfy isDigit)
             return (read xs)

variable :: Parser String
variable = many1 (satisfy isLetter)

command :: Parser Command
command = do
    varName <- variable
    char '='
    n <- expr
    return (Assign varName n)
    <|> do
    e <- expr
    return (Expr e)

----------------------------------------------------------------             
  
main :: IO ()
main
  = do txt <- getContents
       calculator [] (lines txt)

-- | read-eval-print loop
calculator :: Env -> [String] -> IO ()
calculator _ []  = return ()
calculator env (l:ls) = do 
                    let (res, env1) = execute env l
                    putStrLn res
                    calculator env1 ls  

-- | evaluate a single expression
execute :: Env -> String -> (String, Env)
execute env txt
  = case parse command txt of
      [ (cmd, "") ] -> 
        let (res, env1) = evalCommand env cmd
        in (show res, env1)
      _ -> ("parse error; try again", env) 