defmodule Election do
  defstruct name: "",
            candidates: [],
            next_id: 1

  def run() do
    %Election{} |> run()
  end

  def run(%Election{} = election) do
    [IO.ANSI.clear(), IO.ANSI.cursor(0, 0)]
    |> IO.write()

    election
    |> view()
    |> IO.write()

    command = IO.gets("> ")

    election
    |> update(command)
    |> run()
  end

  def run(:quit), do: :quit

  @doc """
  Updates Election Struct, based on provided command.

  ## Parameters

    - election: Election Struct
    - cmd: String based command. Each command can be shortened to what's shown
      in parenthesis.
      - (n)ame command updates the election name
        - example: "n Mayor"
      - (a)dd command adds a new candidate
        - example: "a Will Ferrell"
      - (v)ote command increments the vote count for candidate
        - example: "v 1"
      - (q)uit command returns a quit atom
        - example: "q"
  Returns `Election` struct

  ## Examples
      iex> %Election{} |> Election.update("n Mayor")
      %Election{name: "Mayor"}

      iex> %Election{} |> Election.update("a Will Ferrell")
      %Election{candidates: [Candidate.new(1, "Will Ferrell")], next_id: 2}

      iex> %Election{candidates: [Candidate.new(1, "Will Ferrell")]} |> Election.update("v 1")
      %Election{candidates: [%Candidate{id: 1, name: "Will Ferrell", votes: 1}]}

      iex> %Election{} |> Election.update("q")
      :quit

  """
  def update(%Election{} = election, cmd) when is_binary(cmd) do
    update(election, String.split(cmd))
  end

  def update(%Election{} = election, ["n" <> _ | args]) do
    name = Enum.join(args, " ")
    %{election | name: name}
  end

  def update(%Election{} = election, ["a" <> _ | args]) do
    name = Enum.join(args, " ")
    candidate = Candidate.new(election.next_id, name)
    candidates = [candidate | election.candidates]

    %{election | candidates: candidates, next_id: election.next_id + 1}
  end

  def update(%Election{} = election, ["v" <> _, id]) do
    vote(election, Integer.parse(id))
  end

  def update(%Election{} = _election, ["q" <> _]), do: :quit

  def update(%Election{} = election, invalid_command) when is_list(invalid_command), do: election

  defp vote(%Election{} = election, {id, ""}) do
    candidates = Enum.map(election.candidates, &maybe_inc_vote(&1, id))
    %{election | candidates: candidates}
  end

  defp vote(%Election{} = election, _error), do: election

  defp maybe_inc_vote(%Candidate{} = candidate, id) when is_integer(id) do
    maybe_inc_vote(candidate, candidate.id == id)
  end

  defp maybe_inc_vote(%Candidate{} = candidate, _inc_vote = false), do: candidate

  defp maybe_inc_vote(%Candidate{} = candidate, _inc_vote = true) do
    %{candidate | votes: candidate.votes + 1}
  end

  def view_header(%Election{} = election) do
    [
      "Election for: #{election.name}\n"
    ]
  end

  def view_body(%Election{} = election) do
    election.candidates
    |> sort_candidates_by_votes_desc()
    |> candidates_to_strings()
    |> prepend_candidates_header()
  end

  defp sort_candidates_by_votes_desc(candidates) do
    candidates
    |> Enum.sort(&(&1.votes >= &2.votes))
  end

  defp candidates_to_strings(candidates) do
    candidates
    |> Enum.map(fn %Candidate{id: id, name: name, votes: votes} ->
      "#{id}\t#{votes}\t#{name}\n"
    end)
  end

  defp prepend_candidates_header(candidates) do
    [
      "ID\tVotes\t\Name\n",
      "-----------------------------\n"
      | candidates
    ]
  end

  def view_footer() do
    [
      "\n",
      "commands: (n)ame <election>, (a)dd <candidate>, (v)ote <id>, (q)uit\n"
    ]
  end

  def view(%Election{} = election) do
    [
      view_header(election),
      view_body(election),
      view_footer()
    ]
  end
end
