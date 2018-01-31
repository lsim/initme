module InitMe exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type ScriptType
    = SysV
    | SystemD


type alias Model =
    { workingDirectory : String
    , startCommand : String
    , user : String
    , description : String
    , scriptType : ScriptType
    }


initialModel : Model
initialModel =
    { workingDirectory = ""
    , startCommand = ""
    , user = ""
    , description = ""
    , scriptType = SystemD
    }


type Msg
    = None
    | Generate


view : Model -> Html Msg
view model =
    let
        getScript =
            case model.scriptType of
                SystemD ->
                    viewSystemCtlOutput model

                SysV ->
                    buildSysVInitScript model
    in
        div []
            [ h2 [] [ text "Init Me" ]
            , viewInputs
            , hr [] []
            , text getScript
            ]


viewInputs : Html Msg
viewInputs =
    div []
        [ div [] [ text "Working directory:", input [ type_ "text" ] [] ]
        , div [] [ text "input1", input [ type_ "text" ] [] ]
        , div [] [ text "input1", button [] [ text "Update" ] ]
        ]


viewSystemCtlOutput : Model -> String
viewSystemCtlOutput model =
    let
        printLn txt =
            txt ++ "\n"

        printKeyValue key value =
            printLn key ++ "=" ++ value
    in
        printKeyValue "User" model.user



-- Also known as Linux Standard Base (LSB) init script
-- Template obtained from https://github.com/fhd/init-script-template


buildSysVInitScript : Model -> String
buildSysVInitScript model =
    """
#!/bin/sh
### BEGIN INIT INFO
# Provides:
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start daemon at boot time
# Description:       """ ++ model.description ++ """
### END INIT INFO

dir='""" ++ model.workingDirectory ++ """'
cmd='""" ++ model.startCommand ++ """'
user='""" ++ model.user ++ """'

name=`basename $0`
pid_file="/var/run/$name.pid"
stdout_log="/var/log/$name.log"
stderr_log="/var/log/$name.err"

get_pid() {
    cat "$pid_file"
}

is_running() {
    [ -f "$pid_file" ] && ps -p `get_pid` > /dev/null 2>&1
}

case "$1" in
    start)
    if is_running; then
        echo "Already started"
    else
        echo "Starting $name"
        cd "$dir"
        if [ -z "$user" ]; then
            sudo $cmd >> "$stdout_log" 2>> "$stderr_log" &
        else
            sudo -u "$user" $cmd >> "$stdout_log" 2>> "$stderr_log" &
        fi
        echo $! > "$pid_file"
        if ! is_running; then
            echo "Unable to start, see $stdout_log and $stderr_log"
            exit 1
        fi
    fi
    ;;
    stop)
    if is_running; then
        echo -n "Stopping $name.."
        kill `get_pid`
        for i in 1 2 3 4 5 6 7 8 9 10
        # for i in `seq 10`
        do
            if ! is_running; then
                break
            fi

            echo -n "."
            sleep 1
        done
        echo

        if is_running; then
            echo "Not stopped; may still be shutting down or shutdown may have failed"
            exit 1
        else
            echo "Stopped"
            if [ -f "$pid_file" ]; then
                rm "$pid_file"
            fi
        fi
    else
        echo "Not running"
    fi
    ;;
    restart)
    $0 stop
    if is_running; then
        echo "Unable to stop, will not attempt to start"
        exit 1
    fi
    $0 start
    ;;
    status)
    if is_running; then
        echo "Running"
    else
        echo "Stopped"
        exit 1
    fi
    ;;
    *)
    echo "Usage: $0 {start|stop|restart|status}"
    exit 1
    ;;
esac

exit 0
"""


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        None ->
            ( model, Cmd.none )

        Generate ->
            ( model, Cmd.none )


main : Program Never Model Msg
main =
    Html.program
        { init = ( initialModel, Cmd.none )
        , view = view
        , update = update
        , subscriptions = (\_ -> Sub.none)
        }
