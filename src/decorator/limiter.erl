-module(limiter).

%%--------------------------------------------------------------------
%% include
%%--------------------------------------------------------------------
-include("behavior3.hrl").

%%--------------------------------------------------------------------
%% export API
%%--------------------------------------------------------------------
-export([open/2, tick/2, close/2]).

%%--------------------------------------------------------------------
%% API functions
%%--------------------------------------------------------------------
-spec open(bt_node(), bt_state()) -> bt_state().
open(#{id := ID} = _BTNode, BTState) ->
    blackboard:set(i, 0, ID, BTState).

-spec tick(bt_node(), bt_state()) -> {bt_status(), bt_state()}.
tick(#{id := ID, children := [ChildID], properties := #{max_loop := MaxLoop}} = _BTNode, BTState) ->
    case blackboard:get(i, ID, BTState) of
        I when I < MaxLoop ->
            case base_node:execute(ChildID, BTState) of
                {BTStatus, BTState1} when BTStatus =:= ?BT_SUCCESS orelse BTStatus =:= ?BT_FAILURE ->
                    BTState2 = blackboard:set(i, I + 1, ID, BTState1),
                    {BTStatus, BTState2};
                {BTStatus, BTState1} ->
                    {BTStatus, BTState1}
            end;
        _I ->
            {?BT_FAILURE, BTState}
    end;
tick(_BTNode, BTState) ->
    {?BT_ERROR, BTState}.

-spec close(bt_node(), bt_state()) -> bt_state().
close(#{id := ID} = _BTNode, BTState) ->
    blackboard:remove(i, ID, BTState).

%%--------------------------------------------------------------------
%% Internal functions
%%--------------------------------------------------------------------
