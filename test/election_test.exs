defmodule ElectionTest do
  use ExUnit.Case

  doctest Election

  setup do
    %{election: %Election{}}
  end

  test "updating of the election name from a command", ctx do
    command = "name Will Ferrell"
    election = Election.update(ctx.election, command)

    assert election == %Election{name: "Will Ferrell"}
  end

  test "adding a new candidate from a command", ctx do
    command = "add Will Ferrell"
    election = Election.update(ctx.election, command)

    assert election == %Election{
             candidates: [%Candidate{id: 1, name: "Will Ferrell"}],
             next_id: 2
           }
  end

  test "voting for a candidate from a command", ctx do
    add_command = "add Will Ferrell"
    election = Election.update(ctx.election, add_command)

    vote_command = "vote 1"

    assert election |> Election.update(vote_command) == %Election{
             candidates: [%Candidate{id: 1, name: "Will Ferrell", votes: 1}],
             next_id: 2
           }
  end

  test "invalid command", ctx do
    invalid_command = "invalida_command"
    election = Election.update(ctx.election, invalid_command)
    assert election == ctx.election
  end

  test "quitting the app", ctx do
    quit_command = "q"
    election = Election.update(ctx.election, quit_command)

    assert election == :quit
  end
end
