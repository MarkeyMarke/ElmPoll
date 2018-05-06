import StartApp
import Regex exposing (..)
import Effects exposing (Effects)
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Html exposing (Html, div, input, output, label, text, a)
import Html.Events exposing (on, targetValue)
import Html.Attributes exposing (href, target)
import Signal exposing (Address, Signal, Mailbox, mailbox, message)
import Task exposing (Task)
import Json.Encode as JE exposing (string, encode)
import ElmFire exposing
  ( fromUrl, set, subscribe, valueChanged, noOrder, noLimit
  , Reference, Snapshot, Subscription, Error
  )

--MAILBOX FOR SENDING OUT SIGNALS TO MULTIPLE ADDRESSES, this is used to update signals for all of our URL mailboxes at once
proxy : Mailbox (List (Address a, a))
proxy =
  mailbox []

port broadcast : Signal (Task x (List ()))
port broadcast =
  let
    tasks = List.map (uncurry Signal.send)
  in
    Signal.map (Task.sequence << tasks) proxy.signal


--DATA FOR QUESTION KEY FOR FIREBASE
--Each mailbox has its own values called signals which are updated over time. Addresses point to that signal. 
--Im guessing were initializing a mailbox to have an empty string, then setting that string to a specific firebase url within the port function
--Later on, we can update the signals within our mailboxes using the Signal.map function and the mailboxe's address. I THINK
urlQ : String
urlQ = "https://testproj1-5fbcf.firebaseio.com/QuestionBody/Question"

inputStringQ : Mailbox String
inputStringQ = mailbox ""

port runSet : Signal (Task Error Reference)
port runSet = Signal.map
  (\str -> set (string str) (fromUrl urlQ))
  inputStringQ.signal

--DATA FOR ANSWER1 KEY FOR FIREBASE
urlA1 : String
urlA1 = "https://testproj1-5fbcf.firebaseio.com/QuestionBody/Answer1"

inputStringA1 : Mailbox String
inputStringA1 = mailbox ""

port runSetA1 : Signal (Task Error Reference)
port runSetA1 = Signal.map
  (\str -> set (string str) (fromUrl urlA1))
  inputStringA1.signal

--DATA FOR ANSWER2 KEY FOR FIREBASE
urlA2 : String
urlA2 = "https://testproj1-5fbcf.firebaseio.com/QuestionBody/Answer2"

inputStringA2 : Mailbox String
inputStringA2 = mailbox ""

port runSetA2 : Signal (Task Error Reference)
port runSetA2 = Signal.map
  (\str -> set (string str) (fromUrl urlA2))
  inputStringA2.signal

--DATA FOR ANSWER3 KEY FOR FIREBASE
urlA3 : String
urlA3 = "https://testproj1-5fbcf.firebaseio.com/QuestionBody/Answer3"

inputStringA3 : Mailbox String
inputStringA3 = mailbox ""

port runSetA3 : Signal (Task Error Reference)
port runSetA3 = Signal.map
  (\str -> set (string str) (fromUrl urlA3))
  inputStringA3.signal


--DATA FOR ANSWER4 KEY FOR FIREBASE
urlA4 : String
urlA4 = "https://testproj1-5fbcf.firebaseio.com/QuestionBody/Answer4"

inputStringA4 : Mailbox String
inputStringA4 = mailbox ""

port runSetA4 : Signal (Task Error Reference)
port runSetA4 = Signal.map
  (\str -> set (string str) (fromUrl urlA4))
  inputStringA4.signal

--DATA FOR ANSWER INDEX KEY FOR FIREBASE
urlAI : String
urlAI = "https://testproj1-5fbcf.firebaseio.com/QuestionBody/AnswerIndex"

inputStringAI : Mailbox String
inputStringAI = mailbox ""

port runSetAI : Signal (Task Error Reference)
port runSetAI = Signal.map
  (\str -> set (string str) (fromUrl urlAI))
  inputStringAI.signal



doNothing : a -> Task x ()
doNothing = always (Task.succeed ())

app =
    StartApp.start { init = init, update = update, view = view, inputs = [] }

main = 
    app.html

--INITILIAZATION of our poll elm application, initiliazes with a model and no effect
init : ( Model, Effects Action )
init =
    (model, Effects.none )


--basic implementation of model with a string variable
type alias Model = {
  question : String
  , choice1 : String
  , choice2 : String
  , choice3 : String
  , choice4 : String
  , answerIndex : Int
}
   
--MODEL (Data)
--Set as Type Model
model : Model
--Instantiate Instance Variables
model = Model "Your question will show here." "A goes here." "B goes here." "C goes here." "D goes here." 1



-- UPDATE (Change Data)
-- Define Action (updated to Msg in Elm v18)
-- Action is signal to the system, we use case matching to allow the view section to give a particular signal
type Action = 
  SetQuestion String --sets a new question string
  | SetAnswer Int String --sets a new answer string
  | SetCorrectAnswer Bool Int

--Update takes an Action and a model then returns a tuple of a Model and an Effect (updated to Cmd in v18) with and Action (updated to Msg in Elm v18)
update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    --SetStr will set the string of a model to the input string and pass no Effect thru
    SetQuestion q -> ({model | question = q}, Effects.none)
    SetAnswer int ans -> 
        case int of
            --Generate Updated Clone Copy of Model, this is Elm's equivalent to using a setter for an object
            1 -> ({ model | choice1 = ans},  Effects.none)
            2 -> ({ model | choice2 = ans},  Effects.none)
            3 -> ({ model | choice3 = ans},  Effects.none)
            4 -> ({ model | choice4 = ans},  Effects.none)
            _ -> ({ model | choice1 = ans},  Effects.none)
    SetCorrectAnswer bool num -> 
        case bool of 
            True ->
                ({model | answerIndex = num}, Effects.none)
            False ->
                (model, Effects.none)

-- VIEW 
-- Prints out the values of our model using html
--Text box sends input value and replaces our model's string
-- NO CLUE WHAT SIGNAL.ADDRESS IS
view : Signal.Address Action -> Model -> Html
view address model =
    div [] --View is literally one giant hierarchy of HTML. The first [] is for attributes, and the second [] is for content.
    [ 
    br [] [] --We use an empty br to break down into a new line, or provide spacing.
    
     --Beginning of Questioner's POV
    , fieldset [] 
        [
        div [] [ text "Question ", input [placeholder "Enter your question here.", on "input" targetValue (\str -> Signal.message address (SetQuestion str))] []]
        , br [][], div [][text "Set one answer as the correct answer."], br [][]
        , question address "A" 1
        , br [][]
        , question address "B" 2
        , br [][]
        , question address "C" 3
        , br [][]
        , question address "D" 4
        , br [][]
        --Sends one string to our database
        , button [ onClick proxy.address [(inputStringQ.address, model.question), (inputStringA1.address, model.choice1), 
        (inputStringA2.address, model.choice2), (inputStringA3.address, model.choice3), 
        (inputStringA4.address, model.choice4), (inputStringAI.address, toString (model.answerIndex))]] [ text "Submit" ]
        ]
        
    , br [] [] , br [] []
    , fieldset []
        [
        div [] [text model.question]
        , div [] [text ("A ) " ++ model.choice1)]
        , div [] [text ("B ) " ++ model.choice2)]
        , div [] [text ("C ) " ++ model.choice3)]
        , div [] [text ("D ) " ++ model.choice4)]
        , div [] [text ("The correct answer is " ++ (indexToLetter model.answerIndex) ++ ".")]
        , div [] [text (model.question ++ "%" ++ model.choice1 ++ "%" ++ model.choice2 ++ "%" ++ model.choice3 ++ "%" ++ model.choice4 ++ "%" ++ toString(model.answerIndex))]
        --, div [] [text ((split All (regex "%") appendAllStrings))]  <---splits our string into parseable data
        , br [] []
        ]
      ]



--MIGHT HAVE TO REMOVE THIS
--appends all variables in our poll into a single string. we will send this to our database and parse it later through the answerer's POV
appendAllStrings : String
appendAllStrings = 
    (model.question ++ "%" ++ model.choice1 ++ "%" ++ model.choice2 ++ "%" ++ model.choice3 ++ "%" ++ model.choice4 ++ "%" ++ toString(model.answerIndex))

--converts an index of our answer choices to a corresponding letter
indexToLetter : Int -> String
indexToLetter index =
  case index of
  1 -> "A"
  2 -> "B"
  3 -> "C"
  4 -> "D"
  _ -> ""


{-(Radio Button + Text Box)
Radio Buttons use groupNames to exclude other button in the same group, textValue to provide a text paired up with it,
and newAnswerIndex which takes an int for the new answer index
Takes in groupName to pass into radio, takes in a textValue to assign that button, newAnswerIndex is the new answer -}
question : Signal.Address Action -> String -> Int -> Html
question address textValue newAnswerIndex =
  div []
        [ 
          --beginning of radio button
          label
           [ style [("padding", "20px")]]
           [ input [ type' "radio", name "question", on "input" targetChecked (\bool -> Signal.message address (SetCorrectAnswer bool newAnswerIndex))] [], text textValue]
          --ending of radio button
        , input [ placeholder "Enter your answer here.", on "input" targetValue (\str -> Signal.message address (SetAnswer newAnswerIndex str))] []
        ]